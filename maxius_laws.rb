# lib/maxius_laws.rb
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
      threads = []
      law_links.each_slice(10) do |batch| 
        threads << Thread.new do
          batch.each do |link|
            begin
              law_text = scrape_law_text(link)
              law_name = extract_law_name(link) 
              store_law(law_name, link, law_text)
            rescue OpenURI::HTTPError => e
              puts "HTTP Error scraping #{link}: #{e.message}"
            rescue Nokogiri::CSS::SyntaxError => e
              puts "Error parsing HTML for #{link}: #{e.message}"
            rescue => e
              puts "Error scraping #{link}: #{e.message}"
            end
          end
        end
      end
      threads.each(&:join) 
    end

    def update_laws
      law_links = collect_law_links('https://wetten.overheid.nl/zoeken/geldig')
      threads = []
      law_links.each_slice(10) do |batch| 
        threads << Thread.new do
          batch.each do |link|
            begin
              law_text = scrape_law_text(link)
              law_name = extract_law_name(link)
              if law_exists?(law_name, link)
                update_law(law_name, link, law_text) 
              else
                store_law(law_name, link, law_text)
              end
            rescue OpenURI::HTTPError => e
              puts "HTTP Error updating #{link}: #{e.message}"
            rescue Nokogiri::CSS::SyntaxError => e
              puts "Error parsing HTML for #{link}: #{e.message}"
            rescue => e
              puts "Error updating #{link}: #{e.message}"
            end
          end
        end
      end
      threads.each(&:join) 
    end


    def search_laws(keyword)
      @db.execute("SELECT * FROM laws WHERE name LIKE ? OR text LIKE ?", ["%#{keyword}%", "%#{keyword}%"])
    end

    private

    def collect_law_links(base_url)
      law_links = []
      current_page = 1
      loop do
        url = "#{base_url}?pagina=#{current_page}"
        doc = Nokogiri::HTML(URI.open(url))
        links_on_page = doc.css('a.publication-link')
        break if links_on_page.empty? 
        links_on_page.each do |link|
          law_links << link['href']
        end
        current_page += 1
      end
      law_links
    end

    def scrape_law_text(law_url)
      doc = Nokogiri::HTML(URI.open(law_url))
      law_text_element = doc.css('div.wet-artikelen') 
      law_text_element.css('h2').remove 
      law_text = law_text_element.text.strip 
      law_text
    end

    def extract_law_name(law_url)
      URI.parse(law_url).path.split('/').last.split('-').first
    end

    def store_law(name, url, text)
      @db.execute("INSERT INTO laws (name, url, text) VALUES (?, ?, ?)", [name, url, text])
    end

    def law_exists?(name, url)
      !@db.execute("SELECT * FROM laws WHERE name = ? AND url = ?", [name, url]).empty?
    end

    def update_law(name, url, text)
      @db.execute("UPDATE laws SET text = ? WHERE name = ? AND url = ?", [text, name, url])
    end
  end
end
