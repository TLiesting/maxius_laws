# maxius_laws.gemspec
Gem::Specification.new do |s|
  s.name        = 'maxius_laws'
  s.version     = '0.1.0'
  s.summary     = "A gem to access Dutch law links from Maxius.nl"
  s.authors     = ["Your Name"]
  s.email       = 'your.email@example.com'
  s.files       = ["lib/maxius_laws.rb"]
  s.homepage    = 'https://github.com/your-username/maxius_laws'
  s.license     = 'MIT'
  s.add_runtime_dependency 'nokogiri', '~> 1.13'
end

# lib/maxius_laws.rb
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
      doc.css('.wet_column_middle a').each do |link|
        laws << {
          name: link.text.strip,
          url: link['href']
        }
      end
      laws
    end
  end
end
