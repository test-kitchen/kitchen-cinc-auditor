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
        def load!
          with_warnings_suppressed do
            require 'inspec/dist'
            require 'inspec'
            require 'inspec/plugin/v2'
          end
        end

        def product_name
          dist_const(:PRODUCT_NAME) || 'Cinc Auditor'
        end

        def executable_name
          dist_const(:EXEC_NAME) || 'cinc-auditor'
        end

        def version
          api.const_get(:VERSION)
        end

        def log
          api.const_get(:Log)
        end

        def config_class
          api.const_get(:Config)
        end

        def runner_class
          api.const_get(:Runner)
        end

        def plugin_loader_class
          api.const_get(:Plugin).const_get(:V2).const_get(:Loader)
        end

        def input_registry
          api.const_get(:InputRegistry).instance
        end

        private

        def api
          ::Inspec
        end

        def dist_const(name)
          return unless api.const_defined?(:Dist, false)

          dist = api.const_get(:Dist)
          dist.const_get(name) if dist.const_defined?(name, false)
        end

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
