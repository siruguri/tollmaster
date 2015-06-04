# -*- coding: utf-8 -*-
source 'https://rubygems.org'
ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.2'

gem 'quiet_assets'

# Admin Interface
gem 'rails_admin'

# Use SCSS for stylesheets
gem 'sass-rails', '~>5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Everybody gotta have some Bootstrap!
gem 'jquery-rails'
gem 'bootstrap-sass'

# Needed for default layouts
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'underscore-rails'

# Adding Doorkeeper
gem 'doorkeeper'

# Integrations
gem 'stripe'
gem 'twilio-ruby'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'devise', git: 'https://github.com/plataformatec/devise.git', :branch => 'lm-rails-4-2'
gem 'haml-rails'
gem 'cancan'

gem 'resque-web', require: 'resque_web'
gem 'resque-scheduler'

group :production do
  gem 'pg'
  gem 'execjs'
  gem 'thin'
  # Uncomment this for Heroku
  gem 'rails_12factor'
end

group :development, :test do
  # Use sqlite3 as the database for Active Record in dev and test envs  
  gem 'sqlite3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'

  # Can unset when https://github.com/phusion/passenger/issues/1392 is closed.
  gem 'capistrano-passenger', '0.0.2'
  gem 'capistrano-sidekiq'
end

gem 'dotenv'

#testing with minitest
group :test do
  gem 'selenium-webdriver'
  gem 'mocha'
  gem 'simplecov'
  gem 'webmock'
  gem 'minitest-spec-rails'
  gem 'minitest-rails-capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
end
