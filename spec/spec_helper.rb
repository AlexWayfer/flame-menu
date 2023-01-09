# frozen_string_literal: true

require 'flame'
require 'rack/test'
require 'pry-byebug'

require 'simplecov'

if ENV['CI']
	require 'simplecov-cobertura'
	SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

require_relative '../lib/flame/menu'
