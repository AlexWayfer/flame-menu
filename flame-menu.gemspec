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
		'rubygems_mfa_required' => 'true',
		'source_code_uri' => github_uri,
		'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/main/CHANGELOG.md",
		'wiki_uri' => "#{github_uri}/wiki"
	}

	spec.metadata['homepage_uri'] = github_uri
	spec.homepage = spec.metadata['homepage_uri']

	spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

	spec.required_ruby_version = '>= 3.0', '< 4'

	spec.add_dependency 'flame', '~> 5.0.0.rc6'
end
