# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      # Builds Cinc Auditor runner options for Test Kitchen transports.
      class TransportOptions
        def initialize(instance, config, logger)
          @instance = instance
          @config = config
          @logger = logger
        end

        def build(transport, state)
          method_name = :"build_#{transport.name.downcase}"
          return public_send(method_name, state) if respond_to?(method_name)

          raise Kitchen::UserError, "Verifier #{verifier_name} does not support the #{transport.name} Transport"
        end

        def build_ssh(state)
          Ssh.new(instance, config, logger).build(state)
        end

        def build_winrm(state)
          Winrm.new(instance, config, logger).build(state)
        end

        def build_dokken(state)
          kitchen = connection_options(state)
          options = docker_connection_options(state[:runner_container][:Id], kitchen)
          logger.debug("Connect to Container: #{options['host']}")
          options
        end

        def build_exec(_state)
          {
            'backend' => 'local',
            'logger' => logger
          }
        end

        def build_dockercli(state)
          options = {
            'backend' => 'docker',
            'logger' => logger,
            'host' => state[:container_id]
          }
          logger.debug("Connect to Container: #{options['host']}")
          options
        end

        private

        attr_reader :instance, :config, :logger

        def verifier_name
          'cinc_auditor'
        end

        def connection_options(state)
          instance.transport.send(:connection_options, state).dup
        end

        def docker_connection_options(host, kitchen)
          {
            'backend' => 'docker',
            'logger' => logger,
            'host' => host,
            'connection_timeout' => kitchen[:timeout],
            'connection_retries' => kitchen[:connection_retries],
            'connection_retry_sleep' => kitchen[:connection_retry_sleep],
            'max_wait_until_ready' => kitchen[:max_wait_until_ready]
          }
        end
      end
    end
  end
end

require 'kitchen/verifier/cinc_auditor/transport_options/ssh'
require 'kitchen/verifier/cinc_auditor/transport_options/winrm'
