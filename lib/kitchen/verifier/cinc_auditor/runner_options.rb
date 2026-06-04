# frozen_string_literal: true

require 'kitchen/verifier/cinc_auditor/transport_options'

module Kitchen
  module Verifier
    class CincAuditor
      # Combines transport-specific and common Cinc Auditor runner options.
      class RunnerOptions
        Request = Struct.new(:transport, :state, :platform, :suite, keyword_init: true)

        def initialize(instance, config, logger)
          @config = config
          @transport_options = TransportOptions.new(instance, config, logger)
        end

        def build(request)
          @request = request
          options = transport_options.build(request.transport, request.transport.diagnose.merge(request.state))
          apply_common_options(options)
        end

        private

        attr_reader :config, :request, :transport_options

        def apply_common_options(options)
          options.tap do |runner_options|
            apply_display_options(runner_options)
            apply_reporters(runner_options)
            runner_options[:controls] = config[:controls]
            runner_options[:backend_cache] = config[:backend_cache] || false
          end
        end

        def apply_display_options(options)
          options['color'] = config[:color].nil? || config[:color]
          set_if_configured(options, 'format', :format)
          set_formatted_if_configured(options, 'output', :output)
          set_if_configured(options, 'profiles_path', :profiles_path)
        end

        def apply_reporters(options)
          return if config[:reporter].nil?

          options['reporter'] = config[:reporter].map do |item|
            format_template(item)
          end
        end

        def set_if_configured(options, option_key, config_key)
          options[option_key] = config[config_key] unless config[config_key].nil?
        end

        def set_formatted_if_configured(options, option_key, config_key)
          return if config[config_key].nil?

          options[option_key] = format_template(config[config_key])
        end

        def format_template(value)
          format(value, platform: request.platform, suite: request.suite)
        end
      end
    end
  end
end
