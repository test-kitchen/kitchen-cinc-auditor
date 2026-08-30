# frozen_string_literal: true

require "kitchen/verifier/cinc_auditor/transport_options"

module Kitchen
  module Verifier
    class CincAuditor
      # Combines transport-specific and common Cinc Auditor runner options.
      class RunnerOptions
        # The inputs a runner-option build needs, kept together so the build
        # can be called with one argument instead of four positional ones.
        #
        # @!attribute [rw] transport
        #   @return [Kitchen::Transport::Base] the configured transport
        # @!attribute [rw] state
        #   @return [Hash] instance state
        # @!attribute [rw] platform
        #   @return [String, nil] platform name, for output templating
        # @!attribute [rw] suite
        #   @return [String, nil] suite name, for output templating
        # @!method transport=(value)
        #   @param value [Kitchen::Transport::Base] the transport to build for
        #   @return [Kitchen::Transport::Base] the value written
        # @!method state=(value)
        #   @param value [Hash] the instance state to build from
        #   @return [Hash] the value written
        # @!method platform=(value)
        #   @param value [String, nil] the platform name to template with
        #   @return [String, nil] the value written
        # @!method suite=(value)
        #   @param value [String, nil] the suite name to template with
        #   @return [String, nil] the value written
        Request = Struct.new(:transport, :state, :platform, :suite, keyword_init: true)

        # @param instance [Kitchen::Instance] the instance under test
        # @param config [Hash] the verifier configuration
        # @param logger [Kitchen::Logger] where to report
        def initialize(instance, config, logger)
          @config = config
          @transport_options = TransportOptions.new(instance, config, logger)
        end

        # Builds the complete runner options for one run.
        #
        # Transport-specific options come first, then the display, reporter,
        # and control settings that apply whatever the transport.
        #
        # @param request [Request] what to build for
        # @return [Hash] runner options
        # @raise [Kitchen::UserError] if the transport is not supported
        def build(request)
          @request = request
          options = transport_options.build(request.transport, request.transport.diagnose.merge(request.state))
          apply_common_options(options)
        end

        private

        attr_reader :config, :request, :transport_options

        # @!attribute [r] config
        #   @return [Hash] the verifier configuration
        # @!attribute [r] request
        #   @return [Request, nil] the request being built, nil before {#build}
        # @!attribute [r] transport_options
        #   @return [TransportOptions] builder for the transport-specific half

        # Adds the settings that apply regardless of transport.
        #
        # @param options [Hash] transport options, mutated in place
        # @return [Hash] the same options
        def apply_common_options(options)
          options.tap do |runner_options|
            apply_display_options(runner_options)
            apply_reporters(runner_options)
            runner_options[:controls] = config[:controls]
            runner_options[:backend_cache] = config[:backend_cache] || false
          end
        end

        # Adds colour, format, output, and profile-path settings.
        #
        # Colour defaults to on: it is only disabled when +color+ is set to
        # false explicitly, not merely left unset.
        #
        # @param options [Hash] runner options, mutated in place
        # @return [void]
        def apply_display_options(options)
          options["color"] = config[:color].nil? || config[:color]
          set_if_configured(options, "format", :format)
          set_formatted_if_configured(options, "output", :output)
          set_if_configured(options, "profiles_path", :profiles_path)
        end

        # Adds reporter settings, templating each one.
        #
        # @param options [Hash] runner options, mutated in place
        # @return [void]
        def apply_reporters(options)
          return if config[:reporter].nil?

          options["reporter"] = config[:reporter].map do |item|
            format_template(item)
          end
        end

        # Copies a config value across only when it is set, leaving the
        # runner's own default in place otherwise.
        #
        # @param options [Hash] runner options, mutated in place
        # @param option_key [String, Symbol] key to write
        # @param config_key [Symbol] key to read
        # @return [void]
        def set_if_configured(options, option_key, config_key)
          options[option_key] = config[config_key] unless config[config_key].nil?
        end

        # As {#set_if_configured}, but runs the value through templating.
        #
        # @param options [Hash] runner options, mutated in place
        # @param option_key [String, Symbol] key to write
        # @param config_key [Symbol] key to read
        # @return [void]
        def set_formatted_if_configured(options, option_key, config_key)
          return if config[config_key].nil?

          options[option_key] = format_template(config[config_key])
        end

        # Expands +%{platform}+ and +%{suite}+ in a value, so a reporter can
        # write one file per instance rather than overwriting a shared one.
        #
        # @param value [String] the template
        # @return [String] the expanded value
        # @raise [KeyError] if the template names anything but +platform+ or
        #   +suite+
        def format_template(value)
          format(value, platform: request.platform, suite: request.suite)
        end
      end
    end
  end
end
