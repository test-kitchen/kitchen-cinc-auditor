# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :line

  add_filter "/spec/"
  add_group "Library", "lib"
end

require "tmpdir"
require "fileutils"
require "logger"
require "stringio"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "rspec"

Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |file| require file }

# These specs never load the Cinc Auditor runtime and never talk to an
# instance. Everything this verifier does is turn Test Kitchen configuration
# and transport state into a runner option hash, and turn the runner's exit
# code back into success or a Test Kitchen failure, so all of it can be
# exercised as pure Ruby with the runtime stubbed. Anything that genuinely
# needs a runtime or a container belongs in the Test Kitchen integration
# suites -- see CONTRIBUTING.md.
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # `should` on its own is gone; only `expect` is available.
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect

    # Fail if an example stubs a method the real object does not have. Without
    # this, a rename in lib/ leaves the specs stubbing a method that no longer
    # exists and passing while the verifier is broken.
    mocks.verify_partial_doubles = true
  end

  # No `describe` at the top level, no `should` on every object: RSpec's DSL
  # stays inside RSpec rather than being added to Object and main.
  config.disable_monkey_patching!

  # Metadata on a shared context applies to the groups that include it.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Surface deprecations as failures rather than warnings that scroll past.
  config.raise_errors_for_deprecations!

  config.run_all_when_everything_filtered = true
  config.filter_run_when_matching :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
  Kernel.srand config.seed
end
