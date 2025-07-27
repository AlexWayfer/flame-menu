# frozen_string_literal: true

source 'https://rubygems.org/'

gemspec

group :development do
	gem 'pry-byebug', '~> 3.9'

	gem 'bundler', '~> 2.0'
	gem 'gem_toys', '~> 0.14.0'
	gem 'toys', '~> 0.15.0'
end

group :lint do
	gem 'rubocop', '~> 1.79.0'
	gem 'rubocop-performance', '~> 1.25.0'
	gem 'rubocop-rspec', '~> 3.6.0'
end

group :test do
	gem 'rack-test', '~> 2.0'
	gem 'rspec', '~> 3.9'
	gem 'simplecov', '~> 0.22.0'
	gem 'coveralls_reborn', '~> 0.29.0', require: false
end

group :audit do
	gem 'bundler-audit', '~> 0.9.0'
end
