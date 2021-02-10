# frozen_string_literal: true

require_relative 'lib/flame/menu/version'

Gem::Specification.new do |spec|
	spec.name        = 'flame-menu'
	spec.version     = Flame::Menu::VERSION
	spec.license     = 'MIT'
	spec.summary     = 'Menu for Flame application'
	spec.description = 'Designed for cabinets, includes redirects.'
	spec.authors     = ['Alexander Popov', 'Ivan Tyurin']
	spec.email       = 'alex.wayfer@gmail.com'

	github_uri = "https://github.com/AlexWayfer/#{spec.name}"

	spec.metadata = {
		'source_code_uri' => github_uri,
		'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/master/CHANGELOG.md",
		'wiki_uri' => "#{github_uri}/wiki"
	}

	spec.metadata['homepage_uri'] = github_uri
	spec.homepage = spec.metadata['homepage_uri']

	spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

	spec.required_ruby_version = '>= 2.5', '< 4'

	spec.add_runtime_dependency 'flame', '~> 5.0.0.rc6'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.5.0'
	spec.add_development_dependency 'toys', '~> 0.11.0'

	spec.add_development_dependency 'codecov', '~> 0.2.1'
	spec.add_development_dependency 'rack-test', '~> 1.1'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.20.0'

	spec.add_development_dependency 'bundler-audit', '~> 0.7.0'

	spec.add_development_dependency 'rubocop', '~> 1.4'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
