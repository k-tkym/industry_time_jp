# frozen_string_literal: true

require_relative 'lib/industry_time/version'

Gem::Specification.new do |spec|
  spec.name          = 'industry_time'
  spec.version       = IndustryTime::VERSION
  spec.authors       = ['Kazuki Takayama']
  spec.email         = ['kazuki@example.com']

  spec.summary       = 'Seamlessly handle Japanese industry time (25:00, 28:00) in Ruby.'
  spec.description   = 'Extends Time.parse and Time instances to handle and format 24+ hour times.'
  spec.homepage      = 'https://github.com/k-tkym/industry_time_jp'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.files         = Dir.glob('lib/**/*') + %w[README.md]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
