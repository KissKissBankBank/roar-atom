# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roar/atom/version'

Gem::Specification.new do |spec|
  spec.name          = 'roar-atom'
  spec.version       = Roar::Atom::VERSION
  spec.authors       = ['Fanny Cheung']
  spec.email         = ['fanny@ynote.hk']

  spec.summary       = 'A representable back-end that generates Atom feeds.'
  spec.homepage      = 'https://github.com/KissKissBankBank/roar-atom'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gemfury.com/'
  end

  # Manage representers.
  spec.add_dependency 'roar', '>= 1.0.3'
  spec.add_dependency 'ratom', '>= 0.9.0'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
end
