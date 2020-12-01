# frozen_string_literal: true

require 'flame'
require 'rack/test'
require 'pry-byebug'

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../lib/flame/menu'
