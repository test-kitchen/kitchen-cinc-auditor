# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context 'with a Cinc Auditor verifier'

  it 'uses Test Kitchen verifier API version 1' do
    expect(verifier.diagnose_plugin[:api_version]).to eq(1)
  end

  it 'reports the kitchen-cinc-auditor plugin version' do
    expect(verifier.diagnose_plugin[:version]).to eq(Kitchen::Verifier::CINC_AUDITOR_VERSION)
  end

  describe 'configuration' do
    let(:transport) { Kitchen::Transport::Ssh.new({}) }

    it 'templates reporter paths with platform and suite names' do
      options = verifier.send(:runner_options, transport, {}, 'macos', 'internal')

      expect(options).to include(
        'reporter' => [
          'cli',
          'junit:path/to/results/macos_internal_cinc_auditor.xml'
        ]
      )
    end

    it 'enables backend cache by default' do
      expect(verifier.send(:runner_options, transport)).to include(backend_cache: true)
    end

    it 'defaults backend cache to false when disabled or absent' do
      config[:backend_cache] = nil

      expect(verifier.send(:runner_options, transport)).to include(backend_cache: false)
    end
  end

  describe '#finalize_config!' do
    it 'prefers test/recipes when that legacy cookbook location is present' do
      recipe_tests = File.join(kitchen_root, 'test', 'recipes')
      FileUtils.mkdir_p(recipe_tests)

      expect(verifier[:test_base_path]).to eq(recipe_tests)
    end

    it 'keeps the configured integration test path otherwise' do
      expect(verifier[:test_base_path]).to eq(File.join(kitchen_root, 'test', 'integration'))
    end
  end
end
