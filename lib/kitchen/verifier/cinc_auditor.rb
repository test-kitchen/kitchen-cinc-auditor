# frozen_string_literal: true

require 'kitchen/transport/ssh'
require 'kitchen/transport/winrm'
require 'kitchen/verifier/base'
require 'kitchen/verifier/cinc_auditor_version'

module Kitchen
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

      def finalize_config!(instance)
        super

        recipe_tests = File.join(config[:kitchen_root], 'test', 'recipes')
        config[:test_base_path] = recipe_tests if File.directory?(recipe_tests)

        self
      end

      def call(state)
        logger.debug('Initialize Cinc Auditor')

        runner = build_runner(run_options(state))
        load_targets(runner)
        verify_exit_code(runner.run)
      end

      private

      def run_options(state)
        runner_options_for_state(state).tap do |options|
          logger.debug("Options #{options.inspect}")
          setup_inputs(options, config)
        end
      end

      def runner_options_for_state(state)
        runner_options(instance.transport, state, instance.platform.name, instance.suite.name)
      end

      def build_runner(options)
        initialize_runtime_logging
        load_plugins

        audit_config = audit_config_for(options)
        setup_plugin_config(audit_config)
        runtime.runner_class.new(audit_config)
      end

      def initialize_runtime_logging
        runtime.log.init($stderr)
        runtime.log.level = Kitchen::Util.from_logger_level(logger.level)
      end

      def audit_config_for(options)
        runtime.config_class.new(options)
      end

      def load_targets(runner)
        profile_context = nil
        collect_tests.each do |target|
          profile_context = runner.add_target(target)
        end

        log_profiles(profile_context || [])
      end

      def log_profiles(profile_context)
        profile_context.each { |profile| logger.info("Loaded #{profile.name} ") }
      end

      def verify_exit_code(exit_code)
        return if [0, 101].include?(exit_code)

        raise ActionFailed, "Cinc Auditor Runner returns #{exit_code}"
      end

      def setup_inputs(options, audit_config)
        InputOptions.new.apply(options, audit_config)
      end

      def load_plugins
        PluginOptions.new(config, logger, runtime).load
      end

      def setup_plugin_config(audit_config)
        PluginOptions.new(config, logger, runtime).merge_into(audit_config)
      end

      def load_needed_dependencies!
        runtime.load!
      end

      def local_suite_files
        profile_collection.local_suite_files
      end

      def resolve_config_inspec_tests
        profile_collection.configured_profiles
      end

      def collect_tests
        profile_collection.collect
      end

      def runner_options(transport, state = {}, platform = nil, suite = nil)
        request = RunnerOptions::Request.new(transport: transport, state: state, platform: platform, suite: suite)
        RunnerOptions.new(instance, config, logger).build(request)
      end

      def profile_collection
        ProfileCollection.new(config, logger)
      end

      def runtime
        @runtime ||= Runtime.new
      end
    end
  end
end

require 'kitchen/verifier/cinc_auditor/input_options'
require 'kitchen/verifier/cinc_auditor/plugin_options'
require 'kitchen/verifier/cinc_auditor/profile_collection'
require 'kitchen/verifier/cinc_auditor/runner_options'
require 'kitchen/verifier/cinc_auditor/runtime'
