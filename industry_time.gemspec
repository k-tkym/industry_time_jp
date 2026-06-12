# frozen_string_literal: true

require_relative 'lib/industry_time/version'

Gem::Specification.new do |spec|
  spec.name          = 'industry_time'
  spec.version       = IndustryTime::VERSION
  spec.authors       = ['Kazuki Takayama']
  spec.email         = ['23182248+k-tkym@users.noreply.github.com']

  spec.summary       = 'Seamlessly handle Japanese industry time (25:00, 28:00) in Ruby.'
  spec.description   = 'Extends Time.parse and Time instances to handle and format 24+ hour times.'
  spec.homepage      = 'https://github.com/k-tkym/industry_time_jp'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir.glob('lib/**/*') + %w[README.md README.ja.md CHANGELOG.md LICENSE.txt]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'railties'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
