# frozen_string_literal: true

RSpec.describe Kitchen::Verifier::CincAuditor do
  include_context "with a Cinc Auditor verifier"

  it "uses Test Kitchen verifier API version 1" do
    expect(verifier.diagnose_plugin[:api_version]).to eq(1)
  end

  it "reports the kitchen-cinc-auditor plugin version" do
    expect(verifier.diagnose_plugin[:version]).to eq(Kitchen::Verifier::CINC_AUDITOR_VERSION)
  end

  describe "configuration" do
    let(:transport) { Kitchen::Transport::Ssh.new({}) }

    it "templates reporter paths with platform and suite names" do
      options = verifier.send(:runner_options, transport, {}, "macos", "internal")

      expect(options).to include(
        "reporter" => [
          "cli",
          "junit:path/to/results/macos_internal_cinc_auditor.xml",
        ]
      )
    end

    it "enables backend cache by default" do
      expect(verifier.send(:runner_options, transport)).to include(backend_cache: true)
    end

    it "defaults backend cache to false when disabled or absent" do
      config[:backend_cache] = nil

      expect(verifier.send(:runner_options, transport)).to include(backend_cache: false)
    end
  end

  describe "#finalize_config!" do
    it "prefers test/recipes when that legacy cookbook location is present" do
      recipe_tests = File.join(kitchen_root, "test", "recipes")
      FileUtils.mkdir_p(recipe_tests)

      expect(verifier[:test_base_path]).to eq(recipe_tests)
    end

    it "keeps the configured integration test path otherwise" do
      expect(verifier[:test_base_path]).to eq(File.join(kitchen_root, "test", "integration"))
    end
  end

  describe "#load_needed_dependencies!" do
    it "loads the Cinc Auditor runtime, which Test Kitchen calls it to do" do
      runtime = instance_double(Kitchen::Verifier::CincAuditor::Runtime)
      verifier = described_class.new(config)
      allow(verifier).to receive(:runtime).and_return(runtime)

      expect(runtime).to receive(:load!)

      verifier.send(:load_needed_dependencies!)
    end
  end

  describe "#local_suite_files" do
    it "returns the suite profile Test Kitchen asks the verifier for" do
      suite_path = ensure_suite_directory("default")

      expect(verifier.send(:local_suite_files)).to eq([{ path: suite_path }])
    end

    it "returns nothing when the suite has no profile directory" do
      expect(verifier.send(:local_suite_files)).to eq([])
    end
  end

  describe "exit codes" do
    it "treats 0 as success" do
      expect { verifier.send(:verify_exit_code, 0) }.not_to raise_error
    end

    it "treats 101, an all-skipped run, as success rather than a test failure" do
      expect { verifier.send(:verify_exit_code, 101) }.not_to raise_error
    end

    it "fails on 1, the ordinary control failure code" do
      expect { verifier.send(:verify_exit_code, 1) }
        .to raise_error(Kitchen::ActionFailed, "Cinc Auditor Runner returns 1")
    end

    it "fails on 100, which is one below the skipped code" do
      expect { verifier.send(:verify_exit_code, 100) }
        .to raise_error(Kitchen::ActionFailed, "Cinc Auditor Runner returns 100")
    end

    it "fails on 102, which is one above the skipped code" do
      expect { verifier.send(:verify_exit_code, 102) }
        .to raise_error(Kitchen::ActionFailed, "Cinc Auditor Runner returns 102")
    end
  end
end
