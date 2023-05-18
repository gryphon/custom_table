require_relative "lib/custom_table/version"

Gem::Specification.new do |spec|
  spec.name        = "custom_table"
  spec.version     = CustomTable::VERSION
  spec.authors     = ["Grigory"]
  spec.email       = ["mail@grigor.io"]
  spec.homepage    = "http://github.com/gryphon/custom_table"
  spec.summary     = %q{Easy tables with filters}
  spec.description = %q{Easy tables with filters}
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "capybara"  

  spec.add_dependency "rails", "~> 7.0"
  spec.add_dependency "ransack", '~> 4.0'
  spec.add_dependency "kaminari", '~> 1.2'
  spec.add_dependency "devise", '~> 4.9'
  spec.add_dependency "cancancan"
  spec.add_dependency "haml-rails"
  spec.add_dependency "simple_form"
  spec.add_dependency "caxlsx_rails", '~> 0.6'
end
