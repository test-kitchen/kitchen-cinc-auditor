# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      class TransportOptions
        # Builds Cinc Auditor runner options for SSH transports.
        class Ssh
          def initialize(instance, config, logger)
            @instance = instance
            @config = config
            @logger = logger
          end

          def build(state)
            kitchen = connection_options(state)
            base_options(kitchen).tap do |options|
              add_config_options(options)
              add_bastion_options(options, kitchen)
              add_auth_options(options, kitchen)
            end
          end

          private

          attr_reader :instance, :config, :logger

          def connection_options(state)
            instance.transport.send(:connection_options, state).dup
          end

          def base_options(kitchen)
            {
              'backend' => 'ssh',
              'logger' => logger,
              'sudo' => config[:sudo],
              'sudo_command' => config[:sudo_command],
              'sudo_options' => config[:sudo_options],
              'host' => config[:host] || kitchen[:hostname],
              'port' => config[:port] || kitchen[:port],
              'user' => kitchen[:username]
            }.merge(connection_settings(kitchen))
          end

          def connection_settings(kitchen)
            {
              'keepalive' => kitchen[:keepalive],
              'keepalive_interval' => kitchen[:keepalive_interval],
              'connection_timeout' => kitchen[:timeout],
              'connection_retries' => kitchen[:connection_retries],
              'connection_retry_sleep' => kitchen[:connection_retry_sleep],
              'max_wait_until_ready' => kitchen[:max_wait_until_ready],
              'compression' => kitchen[:compression],
              'compression_level' => kitchen[:compression_level]
            }
          end

          def add_config_options(options)
            add_if_present(options, 'proxy_command', config[:proxy_command])
          end

          def add_bastion_options(options, kitchen)
            add_if_present(options, 'bastion_host', kitchen[:ssh_gateway])
            add_if_present(options, 'bastion_user', kitchen[:ssh_gateway_username])
            add_if_present(options, 'bastion_port', kitchen[:ssh_gateway_port])
          end

          def add_auth_options(options, kitchen)
            add_if_present(options, 'key_files', kitchen[:keys])
            add_if_present(options, 'password', kitchen[:password])
            add_if_present(options, 'forward_agent', config[:forward_agent] || kitchen[:forward_agent])
          end

          def add_if_present(options, key, value)
            options[key] = value unless value.nil?
          end
        end
      end
    end
  end
end
