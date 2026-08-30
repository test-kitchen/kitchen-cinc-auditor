# Runs against a container the driver just started, with nothing converged
# into it, so every control here has to hold for a bare image.

control "reaches-the-container" do
  title "The verifier runs commands inside the Test Kitchen container"

  describe command("echo cinc-auditor") do
    its("exit_status") { should eq 0 }
    its("stdout") { should match(/cinc-auditor/) }
  end
end

control "runs-over-the-docker-backend" do
  title "The runner reads the container's filesystem, not the CI host's"

  # Both platforms are Linux containers. If the verifier connected to the host
  # instead of the container, the family would not be one of these.
  describe os.family do
    it { should be_in %w{debian redhat} }
  end

  describe file("/etc/os-release") do
    it { should exist }
    its("content") { should match(/^ID=/) }
  end
end
