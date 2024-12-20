# frozen_string_literal: true

require_relative 'lib/activejob/web/version'

Gem::Specification.new do |spec|
  spec.name        = 'activejob-web'
  spec.version     = Activejob::Web::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = %w[Prakash Surender Dinesh]
  spec.email       = %w[prakash@mallow-tech.com surender@mallow-tech.com dinesh@mallow-tech.com]
  spec.homepage    = 'https://github.com/mallowtechdev/activejob-web'
  spec.summary     = 'Web-based dashboard for managing and monitoring background jobs'
  spec.description = 'Activejob-web simplifies the background job management in rails'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'https://github.com/mallowtechdev/activejob-web'

  spec.metadata['homepage_uri'] = 'https://github.com/mallowtechdev/activejob-web'
  spec.metadata['source_code_uri'] = 'https://github.com/mallowtechdev/activejob-web'
  spec.metadata['changelog_uri'] = 'https://github.com/mallowtechdev/activejob-web'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'README.md']
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'
  spec.add_dependency 'cloudwatchlogger'
  spec.add_dependency 'rails', '>= 6.1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
