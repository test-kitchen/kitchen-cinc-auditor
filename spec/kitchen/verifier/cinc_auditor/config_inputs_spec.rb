# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context 'with a Cinc Auditor verifier'

  describe '#setup_inputs' do
    let(:options) { {} }

    it 'maps input_files to input_file' do
      verifier.send(:setup_inputs, options, input_files: %w[a.yml b.yml])

      expect(options).to include(input_file: %w[a.yml b.yml])
    end

    it 'maps inputs to string-keyed inputs' do
      verifier.send(:setup_inputs, options, inputs: { region: 'eu-west-2', debug: false })

      expect(options).to include(inputs: { 'region' => 'eu-west-2', 'debug' => false })
    end

    it 'raises a UserError for legacy attrs' do
      expect do
        verifier.send(:setup_inputs, options, attrs: %w[a.yml b.yml])
      end.to raise_error(Kitchen::UserError, /attrs verifier option is no longer supported; use input_files/)
    end

    it 'raises a UserError for legacy attributes' do
      expect do
        verifier.send(:setup_inputs, options, attributes: { user: 'bob' })
      end.to raise_error(Kitchen::UserError, /attributes verifier option is no longer supported; use inputs/)
    end
  end

  describe 'waiver options' do
    it 'uses the singular option key expected by the runner' do
      options = {}

      verifier.send(:setup_inputs, options, waiver_files: ['waivers.yml'])

      expect(options).to include(waiver_file: ['waivers.yml'])
    end

    it 'defaults to an empty waiver file list' do
      options = {}

      verifier.send(:setup_inputs, options, {})

      expect(options).to include(waiver_file: [])
    end
  end

  describe '#load_plugins' do
    let(:loader) { double('Cinc Auditor plugin loader', load_all: nil, exit_on_load_error: nil) }
    let(:loader_class) { double('Cinc Auditor plugin loader class', new: loader) }
    let(:input_registry) { double('Cinc Auditor input registry', :cache_inputs= => nil) }
    let(:runtime) do
      double('Cinc Auditor runtime', plugin_loader_class: loader_class, input_registry: input_registry)
    end

    before do
      stub_cinc_runtime(runtime)
    end

    it 'loads v2 plugins and exits on load errors by default' do
      expect(loader).to receive(:load_all)
      expect(loader).to receive(:exit_on_load_error)

      verifier.send(:load_plugins)
    end

    it 'does not load plugins when disabled' do
      config[:load_plugins] = false

      expect(loader_class).not_to receive(:new)

      verifier.send(:load_plugins)
    end

    it 'sets input cache when cache_inputs is truthy and supported' do
      config[:cache_inputs] = true

      expect(input_registry).to receive(:cache_inputs=).with(true)

      verifier.send(:load_plugins)
    end

    it 'does not set input cache when cache_inputs is false' do
      config[:cache_inputs] = false

      expect(input_registry).not_to receive(:cache_inputs=)

      verifier.send(:load_plugins)
    end
  end

  describe '#setup_plugin_config' do
    it 'merges plugin config when plugin loading is enabled and supported' do
      audit_config = double('Cinc Auditor config')
      config[:plugin_config] = { 'json' => { 'enabled' => true } }

      expect(audit_config).to receive(:merge_plugin_config).with('json', { 'enabled' => true })

      verifier.send(:setup_plugin_config, audit_config)
    end

    it 'does not merge plugin config when plugin loading is disabled' do
      audit_config = double('Cinc Auditor config')
      config[:load_plugins] = false
      config[:plugin_config] = { 'json' => { 'enabled' => true } }

      expect(audit_config).not_to receive(:merge_plugin_config)

      verifier.send(:setup_plugin_config, audit_config)
    end

    it 'warns and skips plugin config when the runtime does not support merging' do
      audit_config = double('Cinc Auditor config')
      config[:plugin_config] = { 'json' => { 'enabled' => true } }

      verifier.send(:setup_plugin_config, audit_config)

      expect(logged_output.string).to include("skipping 'plugin_config'")
    end
  end
end
