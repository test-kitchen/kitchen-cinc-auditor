# The suite writes a JSON reporter file whose name is templated with the
# platform and suite names. CI asserts the file was written.

control "reporter-suite-runs" do
  describe command("true") do
    its("exit_status") { should eq 0 }
  end
end
