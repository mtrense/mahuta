# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mahuta/version'

Gem::Specification.new do |spec|
  spec.name          = 'mahuta'
  spec.version       = Mahuta::VERSION
  spec.authors       = ['Max Trense']
  spec.email         = ['dev@trense.info']

  spec.summary       = %q{Mahuta let's you define forests in neat DSLs.}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://mtrense.github.com'

  spec.files         = Dir[*%W'exe/* lib/**/*.rb Gemfile *.gemspec CODE_OF_CONDUCT.* README.* VERSION']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'simplecov-console', '~> 0.4'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'byebug'
end
