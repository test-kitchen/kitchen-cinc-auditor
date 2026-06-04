# frozen_string_literal: true

require 'pathname'

module Kitchen
  module Verifier
    class CincAuditor
      # Resolves local suite profiles and configured profile targets.
      class ProfileCollection
        FRAMEWORKS = %w[inspec serverspec bats pester rspec cucumber minitest bash].freeze
        RUNNER_KEYS = %i[path url git compliance supermarket branch tag ref relative_path supermarket_url].freeze

        def initialize(config, logger)
          @config = config
          @logger = logger
        end

        def collect
          (local_suite_files + configured_profiles).compact.uniq
        end

        def configured_profiles
          config[:inspec_tests].map { |entry| configured_profile(entry) }
        end

        def local_suite_files
          suite_path = File.join(config[:test_base_path], config[:suite_name])
          test_path = legacy_layout?(suite_path) ? File.join(suite_path, 'inspec') : suite_path

          Pathname.new(test_path).exist? ? [{ path: test_path }] : []
        end

        private

        attr_reader :config, :logger

        def legacy_layout?(suite_path)
          legacy_mode = false

          FRAMEWORKS.each do |framework|
            next unless Pathname.new(File.join(suite_path, framework)).exist?

            logger.info("Detected alternative framework tests for `#{framework}`")
            legacy_mode = true
          end

          legacy_mode
        end

        def configured_profile(entry)
          return profile_hash(entry) if entry.is_a?(Hash)
          return { path: File.expand_path(entry) } if File.exist?(entry)

          entry
        end

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
