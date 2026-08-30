control "configured-profile-runs" do
  title "Reached through the inspec_tests verifier option"

  describe command("echo extra-profile") do
    its("stdout") { should match(/extra-profile/) }
  end
end
