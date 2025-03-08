# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in adjustable_schema.gemspec.
gemspec

gem 'sqlite3'

group :test do
	gem 'simplecov', require: false
end

group :development do
	gem 'rubocop',       require: false
	gem 'rubocop-rails', require: false
end

# CI-specific

case rails_version = ENV.fetch('RAILS_VERSION', :default)
when 'head'
	gem 'rails', github: 'rails/rails'
when /\d+(\.\d+)?/
	gem 'rails', "~> #{rails_version}.0"
end
