# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'puma/metrics/version'

Gem::Specification.new do |spec|
  spec.authors       = ['Harm-Jan Blok']
  spec.description   = 'Puma plugin to export puma stats as prometheus metrics'
  spec.homepage      = 'https://github.com/harmjanblok/puma-metrics'
  spec.license       = 'MIT'
  spec.name          = 'puma-metrics'
  spec.require_paths = ['lib']
  spec.summary       = spec.description
  spec.version       = Puma::Metrics::VERSION

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.metadata['rubygems_mfa_required'] = 'false'

  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'prometheus-client', '>= 0.10'
  spec.add_runtime_dependency 'puma', '>= 6.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'overcommit'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
