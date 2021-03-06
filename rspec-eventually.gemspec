# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/eventually/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-eventually'
  spec.version       = Rspec::Eventually::VERSION
  spec.authors       = ['Hawk Newton']
  spec.email         = ['hawk.newton@gmail.com']
  spec.summary       = 'Make your matchers match eventually'
  spec.description   = 'Enhances rspec DSL to include `eventually` and `eventually_not`'
  spec.homepage      = 'https://github.com/hawknewton/rspec-eventually'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.4'

  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rubocop', '~> 1.3'
end
