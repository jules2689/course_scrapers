# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'einstein/version'

Gem::Specification.new do |spec|
  spec.name          = "einstein"
  spec.version       = Einstein::VERSION
  spec.authors       = ["Julian Nadeau"]
  spec.email         = ["julian@jnadeau.ca"]

  spec.summary       = "Web scrapers for courses"
  spec.description   = "A collection of scrapers that fetch information about courses"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development Dependencies
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.8", ">= 5.8.3"
  spec.add_development_dependency "pry", "~> 0.10.3"
  spec.add_development_dependency "rubocop", "~> 0.35.1"

  # Dependencies
  spec.add_dependency "mechanize", "~> 2.7", ">= 2.7.3"
end
