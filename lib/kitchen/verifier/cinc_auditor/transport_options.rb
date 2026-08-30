# frozen_string_literal: true

module Kitchen
  module Verifier
    class CincAuditor
      # Builds Cinc Auditor runner options for Test Kitchen transports.
      class TransportOptions
        # @param instance [Kitchen::Instance] the instance under test
        # @param config [Hash] the verifier configuration
        # @param logger [Kitchen::Logger] where to report
        def initialize(instance, config, logger)
          @instance = instance
          @config = config
          @logger = logger
        end

        # Builds runner options for whichever transport is configured.
        #
        # Dispatch is by name: the transport's own +name+, lowercased, selects
        # a public +build_<name>+ method, so supporting a new transport is a
        # matter of adding one. +Ssh+ reaches {#build_ssh}, +Winrm+ reaches
        # {#build_winrm}, +Exec+ reaches {#build_exec}, +Dokken+ reaches
        # {#build_dokken}, and +DockerCli+ reaches {#build_dockercli}.
        #
        # @param transport [Kitchen::Transport::Base] the configured transport
        # @param state [Hash] instance state merged over transport diagnostics
        # @return [Hash] runner options for the matching backend
        # @raise [Kitchen::UserError] if the transport has no +build_+ method
        def build(transport, state)
          method_name = :"build_#{transport.name.downcase}"
          return public_send(method_name, state) if respond_to?(method_name)

          raise Kitchen::UserError, "Verifier #{verifier_name} does not support the #{transport.name} Transport"
        end

        # @param state [Hash] instance state
        # @return [Hash] runner options for the SSH backend
        def build_ssh(state)
          Ssh.new(instance, config, logger).build(state)
        end

        # @param state [Hash] instance state
        # @return [Hash] runner options for the WinRM backend
        def build_winrm(state)
          Winrm.new(instance, config, logger).build(state)
        end

        # Options for kitchen-dokken, whose state names the runner container
        # and whose transport supplies the connection timeouts.
        #
        # @param state [Hash] instance state, naming the runner container
        # @return [Hash] runner options for the Docker backend
        def build_dokken(state)
          kitchen = connection_options(state)
          options = docker_connection_options(state[:runner_container][:Id], kitchen)
          logger.debug("Connect to Container: #{options["host"]}")
          options
        end

        # @param _state [Hash] unused; the local backend needs no connection
        # @return [Hash] runner options for the local backend
        def build_exec(_state)
          {
            "backend" => "local",
            "logger" => logger,
          }
        end

        # Options for kitchen-dockercli, which exposes only a container id, so
        # no timeout or retry settings are carried over.
        #
        # @param state [Hash] instance state, naming the container
        # @return [Hash] runner options for the Docker backend
        def build_dockercli(state)
          options = {
            "backend" => "docker",
            "logger" => logger,
            "host" => state[:container_id],
          }
          logger.debug("Connect to Container: #{options["host"]}")
          options
        end

        private

        attr_reader :instance, :config, :logger

        # @!attribute [r] instance
        #   @return [Kitchen::Instance] the instance under test
        # @!attribute [r] config
        #   @return [Hash] the verifier configuration
        # @!attribute [r] logger
        #   @return [Kitchen::Logger] where to report

        # @return [String] this verifier's name, for error messages
        def verifier_name
          "cinc_auditor"
        end

        # The transport's own resolved connection settings.
        #
        # @param state [Hash] instance state
        # @return [Hash] a copy, safe to mutate
        def connection_options(state)
          instance.transport.send(:connection_options, state).dup
        end

        # @param host [String] the container to connect to
        # @param kitchen [Hash] the transport's connection settings
        # @return [Hash] runner options for the Docker backend
        def docker_connection_options(host, kitchen)
          {
            "backend" => "docker",
            "logger" => logger,
            "host" => host,
            "connection_timeout" => kitchen[:timeout],
            "connection_retries" => kitchen[:connection_retries],
            "connection_retry_sleep" => kitchen[:connection_retry_sleep],
            "max_wait_until_ready" => kitchen[:max_wait_until_ready],
          }
        end
      end
    end
  end
end

require "kitchen/verifier/cinc_auditor/transport_options/ssh"
require "kitchen/verifier/cinc_auditor/transport_options/winrm"
