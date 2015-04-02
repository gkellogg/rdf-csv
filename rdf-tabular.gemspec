#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = "rdf-tabular"
  gem.homepage              = "http://github.com/ruby-rdf/rdf-tabular"
  gem.license               = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary               = "Tabular Data RDF Reader and JSON serializer."
  gem.description           = "RDF::Tabular processes tabular data with metadata creating RDF or JSON output."

  gem.authors               = ['Gregg Kellogg']
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('etc/*') + Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w(lib)
  gem.extensions            = %w()
  gem.test_files            = Dir.glob('spec/**')
  gem.has_rdoc              = false

  gem.required_ruby_version = '>= 2.0.0'
  gem.requirements          = []
  gem.add_runtime_dependency     'bcp47',           '~> 0.3', '>= 0.3.3'
  gem.add_runtime_dependency     'rdf',             '~> 1.1', '>= 1.1.7'
  gem.add_runtime_dependency     'rdf-xsd',         '~> 1.1'
  gem.add_runtime_dependency     'json-ld',         '~> 1.1'
  gem.add_runtime_dependency     'addressable',     '~> 2.3'
  gem.add_development_dependency 'yard' ,           '~> 0.8'
  gem.add_development_dependency 'rdf-spec',        '~> 1.1'
  gem.add_development_dependency 'rdf-turtle',      '~> 1.1'
  gem.add_development_dependency 'rdf-isomorphic',  '~> 1.1'
  gem.add_development_dependency 'sparql',          '~> 1.1'
  gem.add_development_dependency 'rspec',           '~> 3.0'
  gem.add_development_dependency 'rspec-its',       '~> 1.0'
  gem.add_development_dependency 'webmock',         '~> 1.17'

  gem.post_install_message  = nil
end
