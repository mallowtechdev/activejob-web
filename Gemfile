source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in activejob-web.gemspec.
gemspec

gem "puma"

gem 'pg'

gem "image_processing", ">= 1.2"

gem "sprockets-rails"

group :development, :test do
  gem 'rspec-rails'
end
gem 'rails-controller-testing', '~> 1.0', '>= 1.0.5'
group :test do
  gem 'factory_bot_rails'
end


# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
