# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      # Handles Cinc Auditor plugin loading and plugin configuration merging.
      class PluginOptions
        # @param config [Hash] the verifier configuration
        # @param logger [Kitchen::Logger] where to report
        # @param runtime [Runtime] the loaded Cinc Auditor runtime
        def initialize(config, logger, runtime)
          @config = config
          @logger = logger
          @runtime = runtime
        end

        # Loads all Cinc Auditor plugins, unless +load_plugins+ is disabled.
        #
        # The loader reports its own failures and exits the process, so a
        # broken plugin never reaches the run as a partially loaded one.
        #
        # @return [void]
        def load
          return unless config[:load_plugins]

          loader = runtime.plugin_loader_class.new
          loader.load_all
          loader.exit_on_load_error
          configure_input_cache
        end

        # Merges +plugin_config+ into the runner config.
        #
        # Older Cinc Auditor versions have no plugin-config merging, so this
        # warns and skips rather than failing the run.
        #
        # @param audit_config [Inspec::Config] the Cinc Auditor config object
        # @return [void]
        def merge_into(audit_config)
          return unless config[:load_plugins]

          return warn_plugin_config_unsupported unless audit_config.respond_to?(:merge_plugin_config)

          merge_plugin_config(audit_config)
        end

        private

        attr_reader :config, :logger, :runtime

        # @!attribute [r] config
        #   @return [Hash] the verifier configuration
        # @!attribute [r] logger
        #   @return [Kitchen::Logger] where to report
        # @!attribute [r] runtime
        #   @return [Runtime] the loaded Cinc Auditor runtime

        # @param audit_config [Inspec::Config] the Cinc Auditor config object
        # @return [void]
        def merge_plugin_config(audit_config)
          config[:plugin_config].each do |plugin_name, plugin_config|
            audit_config.merge_plugin_config(plugin_name, plugin_config)
          end
        end

        # @return [void]
        def warn_plugin_config_unsupported
          logger.warn(
            "kitchen-cinc-auditor: skipping 'plugin_config' because this " \
            "Cinc Auditor version does not expose plugin config merging"
          )
        end

        # Turns on input caching when both +cache_inputs+ is set and the
        # runtime's registry supports it.
        #
        # @return [void]
        def configure_input_cache
          return unless config[:cache_inputs]

          registry = runtime.input_registry
          registry.cache_inputs = true if registry.respond_to?(:cache_inputs=)
        end
      end
    end
  end
end
