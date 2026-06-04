# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      # Handles Cinc Auditor plugin loading and plugin configuration merging.
      class PluginOptions
        def initialize(config, logger)
          @config = config
          @logger = logger
        end

        def load
          return unless config[:load_plugins]

          loader = ::Inspec::Plugin::V2::Loader.new
          loader.load_all
          loader.exit_on_load_error
          configure_input_cache
        end

        def merge_into(audit_config)
          return unless config[:load_plugins]

          return warn_plugin_config_unsupported unless audit_config.respond_to?(:merge_plugin_config)

          merge_plugin_config(audit_config)
        end

        private

        attr_reader :config, :logger

        def merge_plugin_config(audit_config)
          config[:plugin_config].each do |plugin_name, plugin_config|
            audit_config.merge_plugin_config(plugin_name, plugin_config)
          end
        end

        def warn_plugin_config_unsupported
          logger.warn(
            "kitchen-cinc-auditor: skipping 'plugin_config' because this " \
            'Cinc Auditor version does not expose plugin config merging'
          )
        end

        def configure_input_cache
          return unless config[:cache_inputs]

          registry = ::Inspec::InputRegistry.instance
          registry.cache_inputs = true if registry.respond_to?(:cache_inputs=)
        end
      end
    end
  end
end
