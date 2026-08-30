# The suite sets `controls: [selected-control]`. Only the selected control may
# run: the other one fails on purpose, so this suite is red if the filter is
# not applied.

control "selected-control" do
  title "Named in the controls option, so it runs"

  describe command("true") do
    its("exit_status") { should eq 0 }
  end
end

control "excluded-control" do
  title "Not named in the controls option, so it must not run"

  describe command("exit 1") do
    its("exit_status") { should eq 0 }
  end
end
