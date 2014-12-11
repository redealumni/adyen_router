# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adyen_router/version'

Gem::Specification.new do |spec|
  spec.name          = "adyen_router"
  spec.version       = AdyenRouter::VERSION
  spec.authors       = ["Felipe JAPM"]
  spec.email         = ["felipe.japm@gmail.com"]
  spec.summary       = %q{Router Adyen notifications to a specific machine}
  spec.description   = %q{Router Adyen notifications to a specific machine}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thin'
  spec.add_dependency 'sinatra'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
