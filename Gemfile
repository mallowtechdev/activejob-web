# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in activejob-web.gemspec.

gemspec

gem 'puma'

gem 'pg'

gem 'image_processing', '>= 1.2'

gem 'sprockets-rails'

group :development do
  gem 'brakeman'
  gem 'bundler-audit', require: false
  gem 'overcommit', '~> 0.60.0'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
end
gem 'rails-controller-testing', '~> 1.0', '>= 1.0.5'

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
