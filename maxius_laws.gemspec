#maxius_laws.gemspec
Gem::Specification.new do |s|
  s.name        = 'maxius_laws'
  s.version     = '0.1.0'
  s.summary     = "A gem to scrape and store Dutch laws from wetten.overheid.nl"
  s.authors     = ["TLiesting"]
  s.email       = '82956266+TLiesting@users.noreply.github.com'
  s.files       = ["lib/maxius_laws.rb"]
  s.homepage    = 'https://github.com/TLiesting/maxius_laws'
  s.license     = 'MIT'
  s.add_runtime_dependency 'nokogiri', '~> 1.13'
  s.add_runtime_dependency 'sqlite3', '~> 1.4'
end
