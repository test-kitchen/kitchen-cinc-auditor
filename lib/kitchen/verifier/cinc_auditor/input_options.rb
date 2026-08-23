# frozen_string_literal: true

require "hashie"

module Kitchen
  module Verifier
    class CincAuditor
      # Applies input-related verifier config to the Cinc Auditor runner options.
      class InputOptions
        # Applies every input-related setting to the runner options.
        #
        # @param options [Hash] runner options, mutated in place
        # @param audit_config [Hash] the verifier configuration
        # @return [void]
        # @raise [Kitchen::UserError] if a removed legacy option is present
        def apply(options, audit_config)
          validate_supported_inputs(audit_config)
          apply_file_inputs(options, audit_config)
          apply_hash_inputs(options, audit_config)
          apply_waivers(options, audit_config)
        end

        private

        # Rejects the pre-InSpec-4 attribute options with a pointer to their
        # replacements, rather than silently ignoring them.
        #
        # @param audit_config [Hash] the verifier configuration
        # @return [void]
        # @raise [Kitchen::UserError] if +attrs+ or +attributes+ is set
        def validate_supported_inputs(audit_config)
          raise_legacy_input_error(:attrs, :input_files) if audit_config.key?(:attrs)
          raise_legacy_input_error(:attributes, :inputs) if audit_config.key?(:attributes)
        end

        # @param legacy_key [Symbol] the removed option
        # @param replacement_key [Symbol] what to use instead
        # @raise [Kitchen::UserError] always
        def raise_legacy_input_error(legacy_key, replacement_key)
          raise Kitchen::UserError,
            "The #{legacy_key} verifier option is no longer supported; use #{replacement_key} instead"
        end

        # Copies +input_files+ through to the runner.
        #
        # @param options [Hash] runner options, mutated in place
        # @param audit_config [Hash] the verifier configuration
        # @return [void]
        def apply_file_inputs(options, audit_config)
          return unless audit_config[:input_files]

          options[:input_file] = audit_config[:input_files]
        end

        # Copies inline +inputs+ through, stringifying their keys because the
        # runner does not accept symbols.
        #
        # @param options [Hash] runner options, mutated in place
        # @param audit_config [Hash] the verifier configuration
        # @return [void]
        def apply_hash_inputs(options, audit_config)
          return unless audit_config[:inputs]

          options[:inputs] = Hashie.stringify_keys(audit_config[:inputs])
        end

        # Sets the waiver file list, always, so a run that previously had
        # waivers does not inherit them once they are removed.
        #
        # @param options [Hash] runner options, mutated in place
        # @param audit_config [Hash] the verifier configuration
        # @return [void]
        def apply_waivers(options, audit_config)
          options[:waiver_file] = audit_config[:waiver_files] || []
        end
      end
    end
  end
end
