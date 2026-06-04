# frozen_string_literal: true

require 'uri'

module Kitchen
  module Verifier
    class CincAuditor
      class TransportOptions
        # Builds Cinc Auditor runner options for WinRM transports.
        class Winrm
          def initialize(instance, config, logger)
            @instance = instance
            @config = config
            @logger = logger
          end

          def build(state)
            kitchen = connection_options(state)
            endpoint = URI(kitchen[:endpoint])

            base_options(endpoint).merge(auth_options(kitchen)).merge(retry_options(kitchen))
          end

          private

          attr_reader :instance, :config, :logger

          def connection_options(state)
            instance.transport.send(:connection_options, state).dup
          end

          def base_options(endpoint)
            {
              'backend' => 'winrm',
              'logger' => logger,
              'ssl' => endpoint.scheme == 'https',
              'host' => config[:host] || endpoint.hostname,
              'port' => config[:port] || endpoint.port
            }
          end

          def auth_options(kitchen)
            {
              'self_signed' => kitchen[:no_ssl_peer_verification],
              'user' => kitchen[:user],
              'password' => kitchen[:password] || kitchen[:pass]
            }
          end

          def retry_options(kitchen)
            {
              'connection_retries' => kitchen[:connection_retries],
              'connection_retry_sleep' => kitchen[:connection_retry_sleep],
              'max_wait_until_ready' => kitchen[:max_wait_until_ready]
            }
          end
        end
      end
    end
  end
end
