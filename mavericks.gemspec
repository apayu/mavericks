require_relative 'lib/mavericks/version'

Gem::Specification.new do |spec| spec.name          = "mavericks"
  spec.version       = Mavericks::VERSION
  spec.authors       = ["apa yu"]
  spec.email         = ["rx836@hotmail.com"]

  spec.summary       = "build a web framework"
  spec.description   = "base on Rack and Ruby"
  spec.homepage      = "https://github.com/apayu/mavericks"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://github.com/apayu/mavericks"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/apayu/mavericks"
  spec.metadata["changelog_uri"] = "https://github.com/apayu/mavericks"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "erubi"
  spec.add_runtime_dependency "multi_json"
  spec.add_runtime_dependency 'sqlite3'
end
