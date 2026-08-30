# The suite's own profile. It runs alongside the profile named by inspec_tests.

control "local-suite-profile-runs" do
  describe file("/etc") do
    it { should be_directory }
  end
end
