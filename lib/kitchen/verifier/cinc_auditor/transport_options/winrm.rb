# frozen_string_literal: true

require "uri" unless defined?(URI)

module Kitchen
  module Verifier
    class CincAuditor
      class TransportOptions
        # Builds Cinc Auditor runner options for WinRM transports.
        class Winrm
          # @param instance [Kitchen::Instance] the instance under test
          # @param config [Hash] the verifier configuration
          # @param logger [Kitchen::Logger] where to report
          def initialize(instance, config, logger)
            @instance = instance
            @config = config
            @logger = logger
          end

          # Builds the WinRM runner options.
          #
          # @param state [Hash] instance state
          # @return [Hash] runner options for the WinRM backend
          def build(state)
            kitchen = connection_options(state)
            endpoint = URI(kitchen[:endpoint])

            base_options(endpoint).merge(auth_options(kitchen)).merge(retry_options(kitchen))
          end

          private

          attr_reader :instance, :config, :logger

          # @!attribute [r] instance
          #   @return [Kitchen::Instance] the instance under test
          # @!attribute [r] config
          #   @return [Hash] the verifier configuration
          # @!attribute [r] logger
          #   @return [Kitchen::Logger] where to report

          # @param state [Hash] instance state
          # @return [Hash] the transport's resolved settings, safe to mutate
          def connection_options(state)
            instance.transport.send(:connection_options, state).dup
          end

          # Backend, host, and port, derived from the transport's endpoint URL.
          #
          # TLS is inferred from the endpoint's scheme rather than configured
          # separately.
          #
          # @param endpoint [URI] the transport's WinRM endpoint
          # @return [Hash] the backend, TLS, host, and port keys
          def base_options(endpoint)
            {
              "backend" => "winrm",
              "logger" => logger,
              "ssl" => endpoint.scheme == "https",
              "host" => config[:host] || endpoint.hostname,
              "port" => config[:port] || endpoint.port,
            }
          end

          # User, password, and self-signed certificate tolerance.
          #
          # @param kitchen [Hash] the transport's connection settings
          # @return [Hash] the user, password, and self-signed keys
          def auth_options(kitchen)
            {
              "self_signed" => kitchen[:no_ssl_peer_verification],
              "user" => kitchen[:user],
              "password" => kitchen[:password] || kitchen[:pass],
            }
          end

          # Retry and wait settings carried over from the transport.
          #
          # @param kitchen [Hash] the transport's connection settings
          # @return [Hash] the retry and wait keys
          def retry_options(kitchen)
            {
              "connection_retries" => kitchen[:connection_retries],
              "connection_retry_sleep" => kitchen[:connection_retry_sleep],
              "max_wait_until_ready" => kitchen[:max_wait_until_ready],
            }
          end
        end
      end
    end
  end
end
