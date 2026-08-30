# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor::Runtime do
  subject(:runtime) { described_class.new }

  describe "#load!" do
    it "loads the Cinc distribution shim before the shared runtime" do
      expect(runtime).to receive(:require).with("inspec/dist").ordered
      expect(runtime).to receive(:require).with("inspec").ordered
      expect(runtime).to receive(:require).with("inspec/plugin/v2").ordered

      runtime.load!
    end

    it "suppresses warnings while the dist shim redefines constants" do
      verbose_during_load = nil
      allow(runtime).to receive(:require) { verbose_during_load = $VERBOSE }

      runtime.load!

      expect(verbose_during_load).to be_nil
    end

    it "restores the warning setting when a require raises" do
      original_verbose = $VERBOSE
      $VERBOSE = true
      allow(runtime).to receive(:require).and_raise(LoadError, "no such file")

      expect { runtime.load! }.to raise_error(LoadError)
      expect($VERBOSE).to be(true)
    ensure
      $VERBOSE = original_verbose
    end
  end

  describe "distribution metadata" do
    context "when the runtime carries Cinc branding" do
      before do
        stub_const("Inspec", Module.new)
        stub_const("Inspec::Dist", Module.new)
        stub_const("Inspec::Dist::PRODUCT_NAME", "Cinc Auditor")
        stub_const("Inspec::Dist::EXEC_NAME", "cinc-auditor")
      end

      it "reports the Cinc product name" do
        expect(runtime.product_name).to eq("Cinc Auditor")
      end

      it "reports the Cinc executable name" do
        expect(runtime.executable_name).to eq("cinc-auditor")
      end
    end

    context "when the runtime defines no Dist module" do
      before { stub_const("Inspec", Module.new) }

      it "falls back to the Cinc product name" do
        expect(runtime.product_name).to eq("Cinc Auditor")
      end

      it "falls back to the Cinc executable name" do
        expect(runtime.executable_name).to eq("cinc-auditor")
      end
    end

    context "when Dist exists but does not define the branding constants" do
      before do
        stub_const("Inspec", Module.new)
        stub_const("Inspec::Dist", Module.new)
      end

      it "falls back to the Cinc product name" do
        expect(runtime.product_name).to eq("Cinc Auditor")
      end

      it "falls back to the Cinc executable name" do
        expect(runtime.executable_name).to eq("cinc-auditor")
      end
    end
  end

  describe "runtime classes" do
    let(:input_registry) { double("Inspec::InputRegistry") }

    before do
      stub_const("Inspec", Module.new)
      stub_const("Inspec::VERSION", "7.1.7")
      stub_const("Inspec::Log", Class.new)
      stub_const("Inspec::Config", Class.new)
      stub_const("Inspec::Runner", Class.new)
      stub_const("Inspec::Plugin", Module.new)
      stub_const("Inspec::Plugin::V2", Module.new)
      stub_const("Inspec::Plugin::V2::Loader", Class.new)
      registry = input_registry
      stub_const("Inspec::InputRegistry", Class.new { define_singleton_method(:instance) { registry } })
    end

    it "reports the loaded runtime version" do
      expect(runtime.version).to eq("7.1.7")
    end

    it "exposes the runtime logger" do
      expect(runtime.log).to be(Inspec::Log)
    end

    it "exposes the runner config class" do
      expect(runtime.config_class).to be(Inspec::Config)
    end

    it "exposes the runner class" do
      expect(runtime.runner_class).to be(Inspec::Runner)
    end

    it "exposes the v2 plugin loader class" do
      expect(runtime.plugin_loader_class).to be(Inspec::Plugin::V2::Loader)
    end

    it "exposes the input registry singleton" do
      expect(runtime.input_registry).to be(input_registry)
    end
  end
end
