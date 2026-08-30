# The suite directory holds tests for more than one framework, so the verifier
# has to look one level down, in <suite>/inspec, rather than treating the suite
# directory itself as the profile.

control "nested-inspec-directory-is-discovered" do
  describe command("echo nested") do
    its("stdout") { should match(/nested/) }
  end
end
