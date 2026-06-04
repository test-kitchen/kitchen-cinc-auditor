# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context 'with a Cinc Auditor verifier'

  context 'with ssh transport' do
    let(:transport_config) do
      {
        hostname: 'host.example',
        port: 'unused',
        username: 'cinc',
        ssh_key: '/tmp/key',
        keepalive: true,
        keepalive_interval: 30,
        connection_timeout: 10,
        connection_retries: 5,
        connection_retry_sleep: 2,
        max_wait_until_ready: 42,
        compression: true,
        compression_level: 6,
        forward_agent: true
      }
    end
    let(:transport) { Kitchen::Transport::Ssh.new(transport_config) }

    it 'passes SSH connection data and state overrides through to the runner' do
      config[:sudo] = true
      config[:sudo_command] = 'sudo -E'
      config[:sudo_options] = '-H'
      config[:proxy_command] = 'ssh gateway -W %h:%p'

      options = verifier.send(:runner_options, transport, port: 2222)

      expect(options).to include(
        'backend' => 'ssh',
        'logger' => logger,
        'sudo' => true,
        'sudo_command' => 'sudo -E',
        'sudo_options' => '-H',
        'host' => 'host.example',
        'port' => 2222,
        'user' => 'cinc',
        'keepalive' => true,
        'keepalive_interval' => 30,
        'connection_timeout' => 10,
        'connection_retries' => 5,
        'connection_retry_sleep' => 2,
        'max_wait_until_ready' => 42,
        'compression' => true,
        'compression_level' => 6,
        'key_files' => ['/tmp/key'],
        'proxy_command' => 'ssh gateway -W %h:%p',
        'forward_agent' => true
      )
    end

    it 'allows verifier host and port to override Kitchen connection data' do
      config[:host] = '192.168.33.40'
      config[:port] = 222

      options = verifier.send(:runner_options, transport, port: 123)

      expect(options).to include('host' => '192.168.33.40', 'port' => 222)
    end

    it 'passes bastion and password options when Kitchen supplies them' do
      allow(transport).to receive(:connection_options).and_return(
        hostname: 'host.example',
        port: 22,
        username: 'cinc',
        password: 'secret',
        ssh_gateway: 'gateway.example',
        ssh_gateway_username: 'gateway-user',
        ssh_gateway_port: 2200
      )

      options = verifier.send(:runner_options, transport)

      expect(options).to include(
        'password' => 'secret',
        'bastion_host' => 'gateway.example',
        'bastion_user' => 'gateway-user',
        'bastion_port' => 2200
      )
    end

    it 'does not force keys_only true, which would break SSH agent usage' do
      expect(verifier.send(:runner_options, transport)).not_to include('keys_only' => true)
    end
  end

  context 'with winrm transport' do
    let(:transport_config) do
      {
        username: 'Administrator',
        password: 'secret',
        connection_retries: 5,
        connection_retry_sleep: 2,
        max_wait_until_ready: 42
      }
    end
    let(:transport) { Kitchen::Transport::Winrm.new(transport_config) }

    it 'passes WinRM connection data and state through to the runner' do
      options = verifier.send(:runner_options, transport, hostname: 'windows.example', port: 5986)

      expect(options).to include(
        'backend' => 'winrm',
        'logger' => logger,
        'ssl' => false,
        'self_signed' => true,
        'host' => 'windows.example',
        'port' => 5986,
        'user' => 'Administrator',
        'password' => 'secret',
        'connection_retries' => 5,
        'connection_retry_sleep' => 2,
        'max_wait_until_ready' => 42,
        'color' => true
      )
    end

    it 'allows verifier host and port to override Kitchen connection data' do
      config[:host] = '192.168.56.40'
      config[:port] = 5985

      options = verifier.send(:runner_options, transport, hostname: 'windows.example', port: 5986)

      expect(options).to include('host' => '192.168.56.40', 'port' => 5985)
    end
  end

  context 'with exec transport' do
    let(:transport) { Kitchen::Transport::Exec.new }

    it 'uses the local backend' do
      expect(verifier.send(:runner_options, transport)).to include(
        'backend' => 'local',
        'logger' => logger,
        'color' => true
      )
    end
  end

  context 'with dokken transport' do
    let(:transport) { double('Kitchen::Transport::Dokken', name: 'Dokken', diagnose: {}) }

    before do
      allow(transport).to receive(:instance).and_return(instance)
      allow(transport).to receive(:connection_options).and_return(
        timeout: 10,
        connection_retries: 5,
        connection_retry_sleep: 2,
        max_wait_until_ready: 42
      )
    end

    it 'uses the docker backend with the runner container id' do
      options = verifier.send(
        :runner_options,
        transport,
        runner_container: { Id: 'runner-container' }
      )

      expect(options).to include(
        'backend' => 'docker',
        'logger' => logger,
        'host' => 'runner-container',
        'connection_timeout' => 10,
        'connection_retries' => 5,
        'connection_retry_sleep' => 2,
        'max_wait_until_ready' => 42
      )
    end
  end

  context 'with dockercli transport' do
    let(:transport) { double('Kitchen::Transport::DockerCli', name: 'DockerCli', diagnose: {}) }

    before do
      allow(transport).to receive(:instance).and_return(instance)
    end

    it 'uses the docker backend with the container id' do
      options = verifier.send(:runner_options, transport, container_id: 'container-id')

      expect(options).to include(
        'backend' => 'docker',
        'logger' => logger,
        'host' => 'container-id'
      )
    end
  end

  context 'with an unsupported transport' do
    let(:transport) { double('Kitchen::Transport::Dummy', name: 'wickedsauce', diagnose: {}) }

    it 'raises a UserError' do
      expect { verifier.call({}) }.to raise_error(Kitchen::UserError)
    end
  end
end
