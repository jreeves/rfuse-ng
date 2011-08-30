Gem::Specification.new do |s|
  s.name        = "rfuse-ng"
  s.version     = "0.5.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tamás László Fábián"]
  s.email       = ["giganetom@gmail.com"]
  s.homepage    = "http://rubyforge.org/projects/rfuse-ng"
  s.summary     = "Ruby language binding for FUSE"
  s.description = "Ruby language binding for FUSE. It was forked from rfuse"
  s.rubyforge_project = "rfuse-ng"

  s.add_development_dependency("rake")

  s.files            = `git ls-files`.split("\n")
  s.extensions       = 'ext/extconf.rb'
  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = `git ls-files -- LICENSE README*`.split("\n")
end
