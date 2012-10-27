source 'https://rubygems.org'

gem 'rails', '3.2.7'

# test
group :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'fabrication'
  gem 'webmock'
  gem 'jasmine'
end

group :development do
  gem 'spork'
  gem 'simplecov'
  # guard - ruby
  gem 'rb-fsevent'
  gem 'guard-spork'
  gem 'guard-rspec'
  # guard - coffee
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  # notify
  gem 'libnotify' if /linux/ =~ RUBY_PLATFORM
  gem 'rb-inotify' if /linux/ =~ RUBY_PLATFORM
  gem 'growl' if /darwin/ =~ RUBY_PLATFORM
end

# db
group :development do
  gem 'sqlite3'
end
group :production, :test do
  gem 'mysql2'
end

gem 'dalli'

# view
gem 'haml'
gem 'haml-rails'

# assets
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'twitter-bootstrap-rails'

# utils
gem 'rails_config'
gem 'romankana'

# for external web service
gem 'fb_graph'
gem 'youtube_search'
gem 'yacan'
gem 'simple-rss'
gem 'nokogiri'
