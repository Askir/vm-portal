# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

# 
# Rails essentials
# 

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 and postgres as the database for Active Record
gem 'sqlite3', '~> 1.3.6' # development and testing
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets, integrate C implementation of Sass, LibSass, into asset pipeline
gem 'sassc-rails' # https://github.com/sass/sassc-rails
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby
# Turbolinks makes navigating your web application faster
gem 'turbolinks', '~> 5' # https://github.com/turbolinks/turbolinks
# Flexible authentication solution for Rails with Warden
gem 'devise' # https://github.com/plataformatec/devise
gem 'devise-bootstrap-views', '~> 1.0' # https://github.com/hisea/devise-bootstrap-views
gem 'devise-i18n' # https://github.com/tigrish/devise-i18n
# Provides different authentication strategies
gem 'omniauth' # https://github.com/omniauth/omniauth
gem 'omniauth_openid_connect' # https://github.com/m0n9oose/omniauth_openid_connect
# Role management, minimal authorization through OO design and pure Ruby classes
gem 'pundit' # https://github.com/varvet/pundit
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false # https://github.com/Shopify/bootsnap
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

#
# Application
#

# Ruby interface to the VMware vSphere API
gem 'rbvmomi' # https://github.com/vmware/rbvmomi
# Library for using Git in Ruby
gem 'git' # https://github.com/ruby-git/ruby-git
# Allow locks on database
gem 'with_advisory_lock' # https://github.com/ClosureTree/with_advisory_lock
# SSH private and public key generator in pure Ruby (RSA & DSA)
gem 'sshkey', '~> 1.9' # https://github.com/bensie/sshkey
# Mina for deployment
# Tutorial: https://github.com/lnikell/wiki/wiki/Deploy-rails-application-with-Mina,-Nginx-and-Puma
gem 'mina', require: false # https://github.com/mina-deploy/mina
gem 'mina-puma', require: false, github: 'untitledkingdom/mina-puma'
# Adds support for multiple stages to mina
gem 'mina-multistage', require: false # https://github.com/endoze/mina-multistage
# Tail production logs: $ mina logs == tail -f log/production.log
gem 'mina-logs', require: false # https://github.com/windy/mina-logs
# Announce Mina deploys to Slack channels
gem 'execjs', require: false
gem 'mina-slack', require: false, github: 'krichly/mina-slack' # https://github.com/krichly/mina-slack
# Web service for tracking code coverage over time
# https://coveralls.io/github/hpi-swt2/vm-portal
gem 'coveralls', require: false
# Report errors in production to central Errbit system
# https://github.com/errbit/errbit
gem 'airbrake', '~> 5.0' # https://github.com/airbrake/airbrake

#
# Packaged JS, CSS libraries and helpers
#

# Fancy default views and javascript helpers
gem 'bootstrap', '~> 4.3.1' # https://github.com/twbs/bootstrap-rubygem
# jQuery for Rails
gem 'jquery-rails' # https://github.com/rails/jquery-rails
# jQuery datatables Ruby gem for assets pipeline, https://datatables.net/
gem 'jquery-datatables' # https://github.com/mkhairi/jquery-datatables
# The font-awesome font bundled as an asset for the Rails asset pipeline
gem 'font-awesome-rails' # https://github.com/bokmann/font-awesome-rails
# Integrate Select2 javascript library with Rails asset pipeline
gem 'select2-rails' # https://github.com/argerim/select2-rails
# Packaged clipboard.js JS library for copying text to clipboard
gem 'clipboard-rails' # https://github.com/sadiqmmm/clipboard-rails
# Rails form builder for creating forms using Bootstrap 4
gem "bootstrap_form", ">= 4.2.0" # https://github.com/bootstrap-ruby/bootstrap_form
# Deprecated!
# gem 'jquery-turbolinks' # https://github.com/kossnocorp/jquery.turbolinks

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw] # https://github.com/deivid-rodriguez/byebug
  # RSpec testing framework as a drop-in alternative to Rails' default testing framework, Minitest
  gem 'rspec-rails', '~> 3.8' # https://github.com/rspec/rspec-rails
  # State of the art fixtures
  gem 'factory_bot_rails' # https://github.com/thoughtbot/factory_bot_rails
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0' # https://github.com/rails/web-console
  # The Listen gem listens to file modifications and notifies you about the changes.
  gem 'listen', '>= 3.0.5', '< 3.2' # https://github.com/guard/listen
  # Spring speeds up development by keeping your application running in the background
  gem 'spring' # https://github.com/rails/spring
  # Makes Spring watch the filesystem for changes using Listen rather than by polling the filesystem
  gem 'spring-watcher-listen', '~> 2.0.0' # https://github.com/jonleighton/spring-watcher-listen
  # Static code analyzer and formatter, based on the community Ruby style guide
  gem 'rubocop', require: false # https://github.com/rubocop-hq/rubocop
  # Code style checking for RSpec files
  gem 'rubocop-rspec' # https://github.com/rubocop-hq/rubocop-rspec
  # Replaces standard Rails error page with a more useful error page
  # binding_of_caller is optional, but is necessary to use Better Errors' advanced features
  gem 'better_errors' # https://github.com/BetterErrors/better_errors
  gem 'binding_of_caller'
  # Continous execution of unit tests
  gem 'guard' # https://github.com/guard/guard
  # Benchmarking
  # Supporting gem for Rails Panel (Google Chrome extension for Rails development)
  gem 'meta_request' # https://github.com/dejan/rails_panel
  # code profiler for MRI Ruby
  gem 'ruby-prof' # https://github.com/ruby-prof/ruby-prof

end

group :test do
  # Test web applications by simulating how a real user would interact with your app
  gem 'capybara', '>= 2.15' # https://github.com/teamcapybara/capybara
  # Run Selenium tests more easily with automatic installation and updates for all supported webdrivers
  # gem 'webdrivers', '~> 3.0', # https://github.com/titusfortner/webdrivers
  # Ruby bindings for WebDriver
  # gem 'selenium-webdriver', # https://github.com/SeleniumHQ/selenium/tree/master/rb

  # Port of Perl's Data::Faker library that generates fake data
  gem 'faker' # https://github.com/stympy/faker
  # RSpec- and Minitest-compatible one-liners that test common Rails functionality
  # rails-controller-testing is required by shoulda-matchers
  gem 'shoulda-matchers', '4.0.0.rc1' # https://github.com/thoughtbot/shoulda-matchers
  gem 'rails-controller-testing' # https://github.com/rails/rails-controller-testing
  # Code coverage for Ruby
  gem 'simplecov', require: false # https://github.com/colszowka/simplecov
end

group :production do
  gem 'pg' # production database runs on postgres
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

