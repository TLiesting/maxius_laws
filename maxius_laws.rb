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
