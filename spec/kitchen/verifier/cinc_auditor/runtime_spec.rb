# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor::Runtime do
  subject(:runtime) { described_class.new }

  describe '#load!' do
    it 'loads the Cinc distribution shim before the shared runtime' do
      expect(runtime).to receive(:require).with('inspec/dist').ordered
      expect(runtime).to receive(:require).with('inspec').ordered
      expect(runtime).to receive(:require).with('inspec/plugin/v2').ordered

      runtime.load!
    end
  end

  describe 'distribution metadata' do
    before do
      stub_const('Inspec', Module.new)
      stub_const('Inspec::Dist', Module.new)
      stub_const('Inspec::Dist::PRODUCT_NAME', 'Cinc Auditor')
      stub_const('Inspec::Dist::EXEC_NAME', 'cinc-auditor')
    end

    it 'reports the Cinc product name' do
      expect(runtime.product_name).to eq('Cinc Auditor')
    end

    it 'reports the Cinc executable name' do
      expect(runtime.executable_name).to eq('cinc-auditor')
    end
  end
end
