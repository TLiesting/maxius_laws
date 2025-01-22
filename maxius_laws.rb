require 'nokogiri'
require 'open-uri'

module MaxiusLaws
  class LawList
    def initialize(url = 'https://maxius.nl/wetten')
      @url = url
    end

    def laws
      doc = Nokogiri::HTML(URI.open(@url))
      laws = []
      doc.css('.wet_column_middle h1 + ul a').each do |link| 
        laws << {
          name: link.text.strip,
          url: link['href']
        }
      end
      laws
    end
  end
end
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

module MaxiusLaws
  class LawScraper
    def initialize(db_path = 'wetten.db')
      @db = SQLite3::Database.new(db_path)
      create_table
    end

    def create_table
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS laws (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          url TEXT,
          text TEXT
        );
      SQL
    end

    def scrape_and_store
      law_links = collect_law_links('https://wetten.overheid.nl/zoeken/geldig')
      law_links.each do |link|
        begin
          law_text = scrape_law_text(link)
          law_name = extract_law_name(link) # Methode om de naam te extraheren
          store_law(law_name, link, law_text)
        rescue => e
          puts "Error scraping #{link}: #{e.message}"
        end
      end
    end

    private

    def collect_law_links(base_url)
      # ... (zelfde code als in de vorige post)
    end

    def scrape_law_text(law_url)
      # ... (zelfde code als in de vorige post)
    end

    def extract_law_name(law_url)
      # Implementeer logica om de wetnaam uit de URL te halen
      # Bijvoorbeeld:
      # URI.parse(law_url).path.split('/').last.split('-').first
    end

    def store_law(name, url, text)
      @db.execute("INSERT INTO laws (name, url, text) VALUES (?, ?, ?)", [name, url, text])
    end
  end
end
require 'maxius_laws'

scraper = MaxiusLaws::LawScraper.new
scraper.scrape_and_store
