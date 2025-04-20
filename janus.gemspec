# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.1.3'
  spec.name          = 'janus'
  spec.version       = '0.1.0'
  spec.authors       = ['Viktor Bakeev']
  spec.email         = ['acfohegigi@proton.me']

  spec.summary       = 'Janus: database switcher for Rails e2e testing with Sidekiq support'
  spec.description   = 'Janus allows switching databases for end-to-end tests in Rails and Sidekiq environments.'
  spec.homepage      = 'https://github.com/acfohegi/janus'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*', 'app/**/*', 'config/**/*', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 7.0'
  spec.add_dependency 'redis'
  spec.add_dependency 'redis-namespace'
  spec.add_dependency 'sidekiq'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
