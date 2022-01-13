require_relative 'lib/getv/version'

Gem::Specification.new do |spec|
  spec.name          = "getv"
  spec.version       = Getv::VERSION
  spec.authors       = ["harbottle"]
  spec.email         = ["harbottle@room3d3.com"]

  spec.summary       = "Pull package version numbers from the web in various ways."
  spec.description   = "Pull package version numbers from the web in various ways."
  spec.homepage      = "https://github.com/liger1978/getv"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/liger1978/getv"
  spec.metadata["changelog_uri"] = "https://github.com/liger1978/getv"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("nokogiri", ">= 1.0.0")
  spec.add_dependency("octokit", ">= 3.0.0")
  spec.add_dependency("semantic", ">= 1.0.0")
  spec.add_dependency("docker_registry2", ">= 1.0.0")
end
