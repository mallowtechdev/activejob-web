require_relative "lib/activejob/web/version"

Gem::Specification.new do |spec|
  spec.name        = 'activejob-web'
  spec.version     = Activejob::Web::VERSION
  spec.authors     = ["mohammednazeer"]
  spec.email       = ["mohammednazeer@mallow-tech.com"]
  spec.homepage    = 'https://example.com'
  spec.summary     = "Summary of Activejob::Web."
  spec.description = "Description of Activejob::Web."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] =  'http://mygemserver.com'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://example.com'
  spec.metadata["changelog_uri"] = 'https://example.com'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8"
  spec.add_development_dependency 'rspec-rails'
end
