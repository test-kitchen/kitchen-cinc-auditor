# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      # Loads and exposes the Cinc Auditor Ruby runtime.
      #
      # Cinc Auditor packages intentionally preserve the compatible Inspec Ruby
      # namespace. Loading inspec/dist first selects Cinc branding before the
      # shared runtime is loaded.
      class Runtime
        # Requires the Cinc Auditor runtime.
        #
        # +inspec/dist+ is loaded first so Cinc branding is selected before
        # the shared runtime reads it. Warnings are suppressed because the
        # dist shim redefines constants on load.
        #
        # @return [void]
        def load!
          with_warnings_suppressed do
            require "inspec/dist"
            require "inspec"
            require "inspec/plugin/v2"
          end
        end

        # @return [String] the product's display name, e.g. +"Cinc Auditor"+
        def product_name
          dist_const(:PRODUCT_NAME) || "Cinc Auditor"
        end

        # @return [String] the CLI's name, e.g. +"cinc-auditor"+
        def executable_name
          dist_const(:EXEC_NAME) || "cinc-auditor"
        end

        # @return [String] the loaded runtime's version
        def version
          api.const_get(:VERSION)
        end

        # @return [Class] the runtime's logger
        def log
          api.const_get(:Log)
        end

        # @return [Class] the runtime's configuration class
        def config_class
          api.const_get(:Config)
        end

        # @return [Class] the runtime's runner class
        def runner_class
          api.const_get(:Runner)
        end

        # @return [Class] the runtime's v2 plugin loader
        def plugin_loader_class
          api.const_get(:Plugin).const_get(:V2).const_get(:Loader)
        end

        # @return [Object] the runtime's input registry singleton
        def input_registry
          api.const_get(:InputRegistry).instance
        end

        private

        # The runtime's top-level namespace.
        #
        # Cinc Auditor keeps the +Inspec+ namespace deliberately, so that
        # profiles and plugins written for either work unchanged.
        #
        # @return [Module]
        def api
          ::Inspec
        end

        # Reads a branding constant, tolerating a runtime without them.
        #
        # @param name [Symbol] the constant to read
        # @return [String, nil] nil when the runtime defines no Dist module
        def dist_const(name)
          return unless api.const_defined?(:Dist, false)

          dist = api.const_get(:Dist)
          dist.const_get(name) if dist.const_defined?(name, false)
        end

        # Runs the block with Ruby warnings off, restoring the previous
        # setting afterwards even if the block raises.
        #
        # @yield the code to run quietly
        # @return [Object] the block's value
        def with_warnings_suppressed
          original_verbose = $VERBOSE
          $VERBOSE = nil
          yield
        ensure
          $VERBOSE = original_verbose
        end
      end
    end
  end
end
