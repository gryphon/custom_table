$:.push File.expand_path("../lib", __FILE__)
require "custom_table/version"

Gem::Specification.new do |s|
  s.name        = "custom_table"
  s.version     = CustomTable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Grigory"]
  s.email       = ["mail@grigor.io"]
  s.homepage    = "http://github.com/gryphon/custom_table"
  s.summary     = %q{Easy tables with filters}
  s.description = %q{Easy tables with filters}
  
  #s.files         = `git ls-files`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = Dir['assets/**/*']
  
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 7.0"
  s.add_dependency "ransack", '~> 3.2'
  s.add_dependency "kaminari", '~> 1.2'
  s.add_dependency "caxlsx_rails", '~> 0.6'

end