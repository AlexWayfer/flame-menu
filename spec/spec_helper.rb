# frozen_string_literal: true

require 'flame'
require 'rack/test'
require 'pry-byebug'

require 'simplecov'

if ENV['CI']
	require 'coveralls'
	SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start

require_relative '../lib/flame/menu'
