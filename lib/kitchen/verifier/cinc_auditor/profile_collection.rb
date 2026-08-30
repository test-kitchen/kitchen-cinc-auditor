# frozen_string_literal: true

require "pathname" unless defined?(Pathname)

module Kitchen
  module Verifier
    class CincAuditor
      # Resolves local suite profiles and configured profile targets.
      class ProfileCollection
        # Subdirectory holding profiles under the legacy per-framework layout.
        INSPEC_FRAMEWORK = "inspec"

        # Framework subdirectories that mark a suite as using the legacy
        # layout, where tests live one level below the suite directory.
        FRAMEWORKS = %w{inspec serverspec bats pester rspec cucumber minitest bash}.freeze

        # Keys the runner understands in a profile hash. Anything else in a
        # configured entry is dropped before it reaches the runner.
        RUNNER_KEYS = %i{path url git compliance supermarket branch tag ref relative_path supermarket_url}.freeze

        # @param config [Hash] the verifier configuration
        # @param logger [Kitchen::Logger] where to report
        def initialize(config, logger)
          @config = config
          @logger = logger
        end

        # Every profile to run: the suite's own, plus those configured.
        #
        # @return [Array<Hash, String>] profile paths and hashes, deduplicated
        def collect
          (local_suite_files + configured_profiles).compact.uniq
        end

        # Profiles named by the +inspec_tests+ option.
        #
        # @return [Array<Hash, String, nil>] one entry per configured profile
        def configured_profiles
          config[:inspec_tests].map { |entry| configured_profile(entry) }
        end

        # The suite's own profile directory, if it exists.
        #
        # @return [Array<Hash>] a single-entry array, or empty
        def local_suite_files
          suite_path = File.join(config[:test_base_path], config[:suite_name])
          test_path = legacy_layout?(suite_path) ? framework_profile_path(suite_path) : suite_path

          Pathname.new(test_path).exist? ? [{ path: test_path }] : []
        end

        private

        attr_reader :config, :logger

        # @!attribute [r] config
        #   @return [Hash] the verifier configuration
        # @!attribute [r] logger
        #   @return [Kitchen::Logger] where to report

        # Detects the legacy layout, where tests sit in a framework-named
        # subdirectory of the suite rather than the suite directory itself.
        #
        # Every framework is checked rather than stopping at the first, so
        # that each one found is logged.
        #
        # @param suite_path [String] the suite directory
        # @return [Boolean] true when any framework subdirectory exists
        def legacy_layout?(suite_path)
          legacy_mode = false

          FRAMEWORKS.each do |framework|
            next unless Pathname.new(File.join(suite_path, framework)).exist?

            logger.info("Detected alternative framework tests for `#{framework}`")
            legacy_mode = true
          end

          legacy_mode
        end

        # @param suite_path [String] the suite directory
        # @return [String] the suite's +inspec+ subdirectory
        def framework_profile_path(suite_path)
          File.join(suite_path, INSPEC_FRAMEWORK)
        end

        # Normalizes one +inspec_tests+ entry.
        #
        # @param entry [Hash, String] a profile hash, a local path, or a
        #   remote identifier passed through untouched
        # @return [Hash, String, nil] the normalized entry, nil when a hash
        #   entry names nothing the runner understands
        def configured_profile(entry)
          return profile_hash(entry) if entry.is_a?(Hash)
          return { path: File.expand_path(entry) } if File.exist?(entry)

          entry
        end

        # Normalizes a profile given as a hash, expanding any local path and
        # dropping keys the runner does not understand.
        #
        # An entry naming only +name+ is passed through whole, since that
        # selects an already-loaded profile rather than describing a source.
        #
        # @param entry [Hash] the configured profile
        # @return [Hash, nil] nil when nothing usable remains
        def profile_hash(entry)
          profile = entry.dup
          profile[:path] = File.expand_path(profile[:path]) if profile.key?(:path)
          return profile if profile.keys == [:name]

          profile.select! { |key, _value| RUNNER_KEYS.include?(key) }
          profile unless profile.empty?
        end
      end
    end
  end
end
