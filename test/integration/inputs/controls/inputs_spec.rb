# Exercises the inputs, input_files and waiver_files verifier options.

inline_input = input("inline_input")
file_input = input("file_input")

control "inline-inputs-reach-the-profile" do
  title "inputs: from kitchen.yml arrive as profile inputs"

  describe inline_input do
    it { should cmp "from-kitchen-yml" }
  end
end

control "file-inputs-reach-the-profile" do
  title "input_files: are read and merged"

  describe file_input do
    it { should cmp "from-input-file" }
  end
end

control "waived-control" do
  title "waiver_files: waive this control, so its failure is not a run failure"

  describe command("exit 1") do
    its("exit_status") { should eq 0 }
  end
end
