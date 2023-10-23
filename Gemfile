source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in activejob-web.gemspec.

ruby '3.2.2'

gemspec

gem 'puma'

gem 'sqlite3'

gem 'sprockets-rails'

group :development do
  gem 'brakeman'
  gem 'bundler-audit', require: false
  gem 'overcommit', '~> 0.60.0'
end

group :development, :test do
  gem 'rubocop', require: false
end

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
