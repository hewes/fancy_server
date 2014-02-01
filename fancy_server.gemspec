# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fancy_server/version'

Gem::Specification.new do |spec|
  spec.name          = "fancy_server"
  spec.version       = FancyServer::VERSION
  spec.authors       = ["hewes"]
  spec.email         = ["hrysk1986@gmail.com"]
  spec.summary       = %q{fancy_server is library for building mock server.}
  spec.description   = %q{current fancy_server provides API of REST(http) server only.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
