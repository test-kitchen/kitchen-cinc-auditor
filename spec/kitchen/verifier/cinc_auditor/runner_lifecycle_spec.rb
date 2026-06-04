# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context 'with a Cinc Auditor verifier'

  describe '#runner_options' do
    it 'applies common runner options' do
      config[:color] = false
      config[:format] = 'documentation'
      config[:output] = '/tmp/%{platform}_%{suite}.xml'
      config[:profiles_path] = '/tmp/profiles'
      config[:controls] = %w[sshd-1 sshd-2]

      options = verifier.send(:runner_options, transport, {}, 'ubuntu-2204', 'default')

      expect(options).to include(
        'backend' => 'local',
        'color' => false,
        'format' => 'documentation',
        'output' => '/tmp/ubuntu-2204_default.xml',
        'profiles_path' => '/tmp/profiles',
        controls: %w[sshd-1 sshd-2]
      )
    end

    it 'does not forward Chef license settings' do
      config[:chef_license_key] = 'chef-key'
      config[:chef_license_server] = 'https://license.example'

      options = verifier.send(:runner_options, transport)

      expect(options).not_to include(:chef_license_key, :chef_license_server)
      expect(options).not_to include('chef_license_key', 'chef_license_server')
    end
  end

  describe '#call' do
    let(:runner) { double('Cinc Auditor runner', run: exit_code) }
    let(:exit_code) { 0 }
    let(:audit_config) { { audit: 'config' } }
    let(:log_class) { fake_log_class }
    let(:config_class) { fake_config_class(audit_config) }
    let(:runner_class) { double('Cinc Auditor runner class', new: runner) }
    let(:runtime) do
      fake_cinc_runtime(log_class: log_class, config_class: config_class, runner_class: runner_class)
    end

    before do
      stub_cinc_runtime(runtime)
      allow(verifier).to receive(:load_plugins)
      allow(runner).to receive(:add_target).and_return([double('profile', name: 'local')])
    end

    it 'initializes logging, loads plugins, configures the runner, adds targets, and runs' do
      suite_path = ensure_suite_directory('default')

      expect(log_class).to receive(:init).with($stderr)
      expect(verifier).to receive(:load_plugins).ordered
      expect(config_class).to receive(:new)
        .with(hash_including('backend' => 'local')).ordered.and_return(audit_config)
      expect(runner_class).to receive(:new).with(audit_config).ordered.and_return(runner)
      expect(runner).to receive(:add_target)
        .with({ path: suite_path }).ordered.and_return([double('profile', name: 'local')])
      expect(runner).to receive(:run).ordered.and_return(0)

      verifier.call({})

      expect(logged_output.string).to include('Loaded local')
    end

    it 'passes platform and suite names into runner option templates' do
      expect(verifier).to receive(:runner_options).with(
        transport,
        {},
        'ubuntu',
        'default'
      ).and_return({})

      verifier.call({})
    end

    it 'adds local and remote profile targets in order' do
      suite_path = ensure_suite_directory('default')
      config[:inspec_tests] = [{ url: 'https://example.test/profile.zip' }]

      expect(runner).to receive(:add_target).with({ path: suite_path }).ordered.and_return([])
      expect(runner).to receive(:add_target).with({ url: 'https://example.test/profile.zip' }).ordered.and_return([])

      verifier.call({})
    end

    it 'does not add a nonexistent local suite target' do
      expect(runner).not_to receive(:add_target).with(hash_including(path: /nobody/))

      verifier.call({})
    end

    it 'treats exit code 101 as success' do
      allow(runner).to receive(:run).and_return(101)

      expect { verifier.call({}) }.not_to raise_error
    end

    it 'raises ActionFailed for non-success exit codes' do
      allow(runner).to receive(:run).and_return(2)

      expect { verifier.call({}) }.to raise_error(Kitchen::ActionFailed, 'Cinc Auditor Runner returns 2')
    end

    it 'does not add Chef license options from config or environment' do
      old_license_key = ENV.fetch('CHEF_LICENSE_KEY', nil)
      old_license_server = ENV.fetch('CHEF_LICENSE_SERVER', nil)
      config[:chef_license_key] = 'chef-key'
      config[:chef_license_server] = 'https://license.example'
      ENV['CHEF_LICENSE_KEY'] = 'env-chef-key'
      ENV['CHEF_LICENSE_SERVER'] = 'https://env-license.example'

      expect(config_class).to receive(:new).with(
        hash_not_including(:chef_license_key, :chef_license_server, 'chef_license_key', 'chef_license_server')
      ).and_return(audit_config)

      verifier.call({})
    ensure
      restore_env('CHEF_LICENSE_KEY', old_license_key)
      restore_env('CHEF_LICENSE_SERVER', old_license_server)
    end
  end
end
