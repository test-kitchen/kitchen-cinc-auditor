# frozen_string_literal: true

require "kitchen/transport/ssh"
require "kitchen/transport/winrm"
require "kitchen/verifier/base"
require "kitchen/verifier/cinc_auditor_version"

# Test Kitchen's top-level namespace.
module Kitchen
  # Test Kitchen's verifier plugins.
  module Verifier
    # Test Kitchen verifier for Cinc Auditor profiles.
    class CincAuditor < Kitchen::Verifier::Base
      kitchen_verifier_api_version 1
      plugin_version Kitchen::Verifier::CINC_AUDITOR_VERSION
      no_parallel_for :verify

      default_config :inspec_tests, []
      default_config :load_plugins, true
      default_config :plugin_config, {}
      default_config :backend_cache, true

      # Points the verifier at `test/recipes` when that directory exists.
      #
      # @param instance [Kitchen::Instance] the instance being configured
      # @return [self] this verifier, as Test Kitchen's plugin API expects
      def finalize_config!(instance)
        super

        recipe_tests = File.join(config[:kitchen_root], "test", "recipes")
        config[:test_base_path] = recipe_tests if File.directory?(recipe_tests)

        self
      end

      # Runs the Cinc Auditor profiles against the instance.
      #
      # @param state [Hash] instance state describing how to connect
      # @return [void]
      # @raise [Kitchen::UserError] if the transport is unsupported or the
      #   configuration names a removed input option
      # @raise [Kitchen::ActionFailed] if the run reports a failing exit code
      def call(state)
        logger.debug("Initialize Cinc Auditor")

        runner = build_runner(run_options(state))
        load_targets(runner)
        verify_exit_code(runner.run)
      end

      private

      # Builds the full runner option hash for this run.
      #
      # @param state [Hash] instance state
      # @return [Hash] runner options, inputs applied
      # @raise [Kitchen::UserError] if the configuration names a removed
      #   input option
      def run_options(state)
        runner_options_for_state(state).tap do |options|
          logger.debug("Options #{options.inspect}")
          setup_inputs(options, config)
        end
      end

      # @param state [Hash] instance state
      # @return [Hash] runner options for the configured transport
      # @raise [Kitchen::UserError] if the transport is not supported
      def runner_options_for_state(state)
        runner_options(instance.transport, state, instance.platform.name, instance.suite.name)
      end

      # Loads the runtime, its plugins, and builds a runner.
      #
      # @param options [Hash] runner options
      # @return [Inspec::Runner] a runner configured for this instance
      def build_runner(options)
        initialize_runtime_logging
        load_plugins

        audit_config = audit_config_for(options)
        setup_plugin_config(audit_config)
        runtime.runner_class.new(audit_config)
      end

      # Points Cinc Auditor's logger at stderr, at Test Kitchen's level.
      #
      # @return [void]
      def initialize_runtime_logging
        runtime.log.init($stderr)
        runtime.log.level = Kitchen::Util.from_logger_level(logger.level)
      end

      # @param options [Hash] runner options
      # @return [Inspec::Config] the runner configuration for those options
      def audit_config_for(options)
        runtime.config_class.new(options)
      end

      # Adds every collected profile to the runner.
      #
      # @param runner [Inspec::Runner] the Cinc Auditor runner
      # @return [void]
      def load_targets(runner)
        profile_context = nil
        collect_tests.each do |target|
          profile_context = runner.add_target(target)
        end

        log_profiles(profile_context || [])
      end

      # Logs the name of each profile that was loaded.
      #
      # @param profile_context [Enumerable] loaded profiles
      # @return [void]
      def log_profiles(profile_context)
        profile_context.each { |profile| logger.info("Loaded #{profile.name} ") }
      end

      # Turns a runner exit code into success or a Test Kitchen failure.
      #
      # Cinc Auditor distinguishes its outcomes: 0 is a clean run, 100 means
      # at least one control failed or errored, 101 means at least one control
      # was skipped and none failed, and 102 means a profile could not be
      # loaded. 1 covers usage and general errors, and is also what the
      # runner returns for a failure when distinct exit codes are turned off.
      #
      # 101 is treated as success alongside 0, because a skip is not a test
      # failure. Every other code fails the verify action.
      #
      # @param exit_code [Integer] the runner's exit status
      # @return [void]
      # @raise [Kitchen::ActionFailed] on any code other than 0 or 101
      def verify_exit_code(exit_code)
        return if [0, 101].include?(exit_code)

        raise ActionFailed, "Cinc Auditor Runner returns #{exit_code}"
      end

      # Applies input files, inline inputs, and waivers to the options.
      #
      # @param options [Hash] runner options, mutated in place
      # @param audit_config [Hash] the verifier configuration
      # @return [void]
      # @raise [Kitchen::UserError] if a removed legacy input option is set
      def setup_inputs(options, audit_config)
        InputOptions.new.apply(options, audit_config)
      end

      # Loads Cinc Auditor plugins, when enabled.
      #
      # @return [void]
      def load_plugins
        PluginOptions.new(config, logger, runtime).load
      end

      # Merges configured plugin settings into the runner config.
      #
      # @param audit_config [Inspec::Config] the Cinc Auditor config object
      # @return [void]
      def setup_plugin_config(audit_config)
        PluginOptions.new(config, logger, runtime).merge_into(audit_config)
      end

      # Loads the Cinc Auditor runtime. Called by Test Kitchen.
      #
      # @return [void]
      # @raise [LoadError] if the Cinc Auditor runtime is not installed
      def load_needed_dependencies!
        runtime.load!
      end

      # @return [Array<Hash>] the suite's own profile, if it has one
      def local_suite_files
        profile_collection.local_suite_files
      end

      # @return [Array<Hash, String, nil>] profiles named by the +inspec_tests+
      #   option; a configured hash naming no runner key resolves to nil
      def resolve_config_inspec_tests
        profile_collection.configured_profiles
      end

      # @return [Array<Hash, String>] every profile to run, local and
      #   configured, deduplicated
      def collect_tests
        profile_collection.collect
      end

      # Builds runner options for a transport.
      #
      # @param transport [Kitchen::Transport::Base] the configured transport
      # @param state [Hash] instance state
      # @param platform [String, nil] platform name, for output templating
      # @param suite [String, nil] suite name, for output templating
      # @return [Hash] runner options
      # @raise [Kitchen::UserError] if the transport is not supported
      def runner_options(transport, state = {}, platform = nil, suite = nil)
        request = RunnerOptions::Request.new(transport: transport, state: state, platform: platform, suite: suite)
        RunnerOptions.new(instance, config, logger).build(request)
      end

      # @return [ProfileCollection] resolver for this suite's profiles
      def profile_collection
        ProfileCollection.new(config, logger)
      end

      # @return [Runtime] the loaded Cinc Auditor runtime
      def runtime
        @runtime ||= Runtime.new
      end
    end
  end
end

require "kitchen/verifier/cinc_auditor/input_options"
require "kitchen/verifier/cinc_auditor/plugin_options"
require "kitchen/verifier/cinc_auditor/profile_collection"
require "kitchen/verifier/cinc_auditor/runner_options"
require "kitchen/verifier/cinc_auditor/runtime"
