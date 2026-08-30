# Not run by this verifier. Its presence is what makes the suite directory a
# multi-framework layout, which is the case the sibling inspec/ directory
# covers.
describe "placeholder" do
  it "is never executed by the cinc_auditor verifier" do
    raise "the cinc_auditor verifier must not load serverspec tests"
  end
end
