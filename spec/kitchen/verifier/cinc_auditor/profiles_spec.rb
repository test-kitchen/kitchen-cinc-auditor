# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context 'with a Cinc Auditor verifier'

  describe '#resolve_config_inspec_tests' do
    it 'keeps remote strings for Cinc Auditor to resolve' do
      config[:inspec_tests] = ['https://example.test/profile.tar.gz']

      expect(verifier.send(:resolve_config_inspec_tests)).to eq(['https://example.test/profile.tar.gz'])
    end

    it 'normalizes local string paths to profile hashes' do
      profile_path = File.join(kitchen_root, 'profile')
      FileUtils.mkdir_p(profile_path)
      config[:inspec_tests] = [profile_path]

      expect(verifier.send(:resolve_config_inspec_tests)).to eq([{ path: profile_path }])
    end

    it 'expands hash path entries and drops non-runner keys' do
      config[:inspec_tests] = [{ name: 'profile', path: 'test/integration/profile', ignored: true }]

      expect(File).to receive(:expand_path).with('test/integration/profile').and_return('/abs/profile')

      expect(verifier.send(:resolve_config_inspec_tests)).to eq([{ path: '/abs/profile' }])
    end

    it 'keeps remote runner keys and removes decoration keys' do
      config[:inspec_tests] = [
        { name: 'profile1', git: 'https://example.test/profile.git', ignored: true },
        { name: 'profile2', compliance: 'base/ssh', random: 'value' },
        { name: 'profile3', supermarket: 'hardening/ssh', supermarket_url: 'https://supermarket.example' },
        { name: 'profile4', url: 'https://example.test/profile.zip', branch: 'main', tag: 'v1', ref: 'abc' },
        { name: 'profile5', relative_path: 'profiles/linux' }
      ]

      expect(verifier.send(:resolve_config_inspec_tests)).to eq(
        [
          { git: 'https://example.test/profile.git' },
          { compliance: 'base/ssh' },
          { supermarket: 'hardening/ssh', supermarket_url: 'https://supermarket.example' },
          { url: 'https://example.test/profile.zip', branch: 'main', tag: 'v1', ref: 'abc' },
          { relative_path: 'profiles/linux' }
        ]
      )
    end

    it 'keeps name-only profiles for Supermarket resolution' do
      config[:inspec_tests] = [{ name: 'owner/profile' }]

      expect(verifier.send(:resolve_config_inspec_tests)).to eq([{ name: 'owner/profile' }])
    end

    it 'returns nil for hashes with no acceptable runner keys' do
      config[:inspec_tests] = [{ ignored: true }]

      expect(verifier.send(:resolve_config_inspec_tests)).to eq([nil])
    end
  end

  describe '#collect_tests' do
    it 'finds the suite profile under test/integration' do
      suite_path = ensure_suite_directory('default')

      expect(verifier.send(:collect_tests)).to eq([{ path: suite_path }])
    end

    it 'uses a nested inspec directory when sibling framework directories exist' do
      suite_path = ensure_suite_directory('default')
      FileUtils.mkdir_p(File.join(suite_path, 'serverspec'))
      FileUtils.mkdir_p(File.join(suite_path, 'inspec'))

      expect(verifier.send(:collect_tests)).to eq([{ path: File.join(suite_path, 'inspec') }])
      expect(logged_output.string).to include('Detected alternative framework tests for `inspec`')
      expect(logged_output.string).to include('Detected alternative framework tests for `serverspec`')
    end

    it 'deduplicates configured profiles and discovered local profiles' do
      suite_path = ensure_suite_directory('default')
      config[:inspec_tests] = [suite_path]

      expect(verifier.send(:collect_tests)).to eq([{ path: suite_path }])
    end

    it 'combines local and remote profiles in order' do
      suite_path = ensure_suite_directory('default')
      config[:inspec_tests] = [{ url: 'https://example.test/profile.zip' }]

      expect(verifier.send(:collect_tests)).to eq(
        [
          { path: suite_path },
          { url: 'https://example.test/profile.zip' }
        ]
      )
    end

    it 'returns only configured profiles when the local suite directory is absent' do
      config[:inspec_tests] = [{ url: 'https://example.test/profile.zip' }]

      expect(verifier.send(:collect_tests)).to eq([{ url: 'https://example.test/profile.zip' }])
    end
  end
end
