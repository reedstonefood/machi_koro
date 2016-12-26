# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'machi_koro/version'

Gem::Specification.new do |spec|
  spec.name          = "machi_koro"
  spec.version       = MachiKoro::VERSION
  spec.authors       = ["reedstonefood"]
  spec.email         = ["reedstonefood@users.noreply.github.com"]

  spec.summary       = %q{An implementation of the board game, Machi Koro.}
  spec.description   = %q{An implementation of the board game, Machi Koro, and its expansions.}
  spec.homepage      = "https://reedstonefood.github.io/machi_koro"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  
  spec.add_dependency "sqlite3", "~> 1.3"
  spec.add_dependency "highline", "~> 1.7"
end
