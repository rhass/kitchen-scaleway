# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/scaleway_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-scaleway'
  spec.version       = Kitchen::Driver::SCALEWAY_VERSION
  spec.authors       = ['Ryan Hass']
  spec.email         = ['ryan@invalidchecksum.net']
  spec.description   = %q{A Test Kitchen Driver for Scaleway}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/rhass/kitchen-scaleway'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.4'
  spec.add_dependency 'scaleway', '~> 1.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'countloc'
end
