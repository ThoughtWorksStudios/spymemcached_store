# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spymemcached_store/version'

Gem::Specification.new do |spec|
  spec.name          = "spymemcached_store"
  spec.version       = SpymemcachedStore::VERSION
  spec.platform      = 'java'
  spec.authors       = ["Xiao Li"]
  spec.email         = ["swing1979@gmail.com"]
  spec.summary       = %q{Rails 3 & 4 cache store for spymemcached.jruby.}
  spec.description   = %q{Rails 3 & 4 cache store for spymemcached.jruby.}
  spec.homepage      = "https://github.com/ThoughtWorksStudios/spymemcached_store"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "spymemcached.jruby"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency 'minitest', '~> 5.1'

end
