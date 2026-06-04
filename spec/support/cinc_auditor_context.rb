# frozen_string_literal: true

require 'kitchen/verifier/cinc_auditor'
require 'kitchen/transport/exec'
require 'kitchen/transport/ssh'
require 'kitchen/transport/winrm'

RSpec.shared_context 'with a Cinc Auditor verifier' do
  let(:kitchen_root) { Dir.mktmpdir }
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:platform) { instance_double('Kitchen::Platform', name: 'ubuntu') }
  let(:suite) { instance_double('Kitchen::Suite', name: 'default') }
  let(:transport_config) { {} }
  let(:transport) { Kitchen::Transport::Exec.new(transport_config) }
  let(:config) do
    {
      kitchen_root: kitchen_root,
      test_base_path: File.join(kitchen_root, 'test', 'integration'),
      backend_cache: true,
      reporter: [
        'cli',
        'junit:path/to/results/%{platform}_%{suite}_cinc_auditor.xml'
      ]
    }
  end
  let(:instance) do
    instance_double(
      'Kitchen::Instance',
      name: 'default-ubuntu',
      logger: logger,
      platform: platform,
      suite: suite,
      transport: transport,
      to_str: 'instance'
    )
  end
  let(:verifier) { described_class.new(config).finalize_config!(instance) }

  before do
    allow_any_instance_of(described_class).to receive(:load_needed_dependencies!)
    allow(transport).to receive(:instance).and_return(instance)
  end

  after do
    FileUtils.remove_entry(kitchen_root)
  end

  def ensure_suite_directory(suite_name)
    suite_path = File.join(config[:test_base_path], suite_name)
    FileUtils.mkdir_p(suite_path)
    suite_path
  end

  def stub_inspec_plugin_runtime(loader_class, input_registry_class)
    stub_const('Inspec', Module.new)
    stub_const('Inspec::Plugin', Module.new)
    stub_const('Inspec::Plugin::V2', Module.new)
    stub_const('Inspec::Plugin::V2::Loader', loader_class)
    stub_const('Inspec::InputRegistry', input_registry_class)
  end

  def stub_inspec_call_runtime(audit_config)
    stub_const('Inspec', Module.new)
    stub_const('Inspec::VERSION', '7.1.7')
    stub_const('Inspec::Log', fake_log_class)
    stub_const('Inspec::Config', fake_config_class(audit_config))
    stub_const('Inspec::Runner', Class.new)
  end

  def fake_log_class
    Class.new do
      class << self
        attr_accessor :level

        def init(_io); end
      end
    end
  end

  def fake_config_class(audit_config)
    Class.new do
      define_singleton_method(:new) do |_options|
        audit_config
      end
    end
  end

  def restore_env(name, value)
    if value.nil?
      ENV.delete(name)
    else
      ENV[name] = value
    end
  end
end
