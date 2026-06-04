# frozen_string_literal: true

require 'hashie'

module Kitchen
  module Verifier
    class CincAuditor
      # Applies input-related verifier config to the Cinc Auditor runner options.
      class InputOptions
        def apply(options, audit_config)
          validate_supported_inputs(audit_config)
          apply_file_inputs(options, audit_config)
          apply_hash_inputs(options, audit_config)
          apply_waivers(options, audit_config)
        end

        private

        def validate_supported_inputs(audit_config)
          raise_legacy_input_error(:attrs, :input_files) if audit_config.key?(:attrs)
          raise_legacy_input_error(:attributes, :inputs) if audit_config.key?(:attributes)
        end

        def raise_legacy_input_error(legacy_key, replacement_key)
          raise Kitchen::UserError,
                "The #{legacy_key} verifier option is no longer supported; use #{replacement_key} instead"
        end

        def apply_file_inputs(options, audit_config)
          return unless audit_config[:input_files]

          options[:input_file] = audit_config[:input_files]
        end

        def apply_hash_inputs(options, audit_config)
          return unless audit_config[:inputs]

          options[:inputs] = Hashie.stringify_keys(audit_config[:inputs])
        end

        def apply_waivers(options, audit_config)
          options[:waiver_file] = audit_config[:waiver_files] || []
        end
      end
    end
  end
end
