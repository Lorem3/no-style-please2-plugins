# frozen_string_literal: true

require_relative "lib/version/version"

Gem::Specification.new do |spec|
  spec.name = "no-style-please2-plugins"
  spec.version = NoStylePlease2::VERSION
  spec.authors = ["vitock"]
  spec.email = [""]
  
  spec.summary = "plugins for jekyll theme no-style-please2"
  spec.description = "plugins for jekyll theme no-style-please2  .  "
  spec.homepage = "https://github.com/vitock/no-style-please2-plugins"
  spec.required_ruby_version = ">= 2.6.0"

  

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vitock/no-style-please2-plugins"
  spec.metadata["changelog_uri"] = "https://github.com/vitock/no-style-please2-plugins/blob/main/LICENSE"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]



  spec.add_dependency "jekyll", "~>4.0"
  spec.add_dependency "ltec", "~> 0.1.4"
  # spec.add_dependency "salsa20", "~> 0.1.3"
  spec.add_dependency "digest"
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
