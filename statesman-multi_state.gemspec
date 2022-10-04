require_relative "lib/statesman/multi_state/version"

Gem::Specification.new do |spec|
  spec.name        = "statesman-multi_state"
  spec.version     = Statesman::MultiState::VERSION
  spec.authors     = ["Chedli Bourguiba"]
  spec.email       = ["bourguiba.chedli@gmail.com"]
  spec.homepage    = "https://github.com/chaadow/statesman-multi_state"
  spec.summary     = "Handle multi state for statesman through has_one_state_machine"
  spec.description = "Handle multi state for statesman through `has_one_state_machine` ActiveRecord macro"
  spec.license     = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/chaadow/statesman-multi_state/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6"
  spec.add_dependency "statesman", ">= 9.0.0"
end
