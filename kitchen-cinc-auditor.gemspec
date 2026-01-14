lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/verifier/cinc_auditor_version"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-cinc-auditor"
  spec.version       = Kitchen::Verifier::CINC_AUDITOR_VERSION
  spec.license       = "Apache-2.0"
  spec.authors       = ["Chef Software, Inc."]
  spec.email         = ["info@chef.io"]

  spec.summary       = "A Test Kitchen Verifier for Cinc Auditor"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/test-kitchen/kitchen-cinc-auditor"

  spec.files         = `git ls-files -z`.split("\x0").grep(/LICENSE|^lib/)
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7.0"
  # TODO: Change to cinc-auditor-bin once it's published to RubyGems
  # For now, using inspec-core for compatibility testing
  spec.add_dependency "inspec-core", ">= 2.2.64", "< 8.0" # 2.2.64 is required for plugin v2 support & Cinc Auditor 6 included
  spec.add_dependency "train"
  spec.add_dependency "hashie", ">= 3.4", "< 6.0"
  if ENV["CHEF_TEST_KITCHEN_ENTERPRISE"]
    spec.add_dependency "chef-test-kitchen-enterprise", ">= 1.1.4", "< 3"
  else
    spec.add_dependency "test-kitchen", ">= 2.7", "< 5"
  end
end
