# Quick Start Guide for kitchen-cinc-auditor

Get up and running with kitchen-cinc-auditor in 5 minutes!

## 1. Install Cinc Auditor

```bash
gem install cinc-auditor-bin
```

## 2. Install kitchen-cinc-auditor

Add to your `Gemfile`:

```ruby
gem 'kitchen-cinc-auditor'
```

Or install directly:

```bash
gem install kitchen-cinc-auditor
```

## 3. Configure Your .kitchen.yml

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

verifier:
  name: cinc_auditor  # That's it!

platforms:
  - name: ubuntu-24.04

suites:
  - name: default
    run_list:
      - recipe[mycookbook::default]
```

## 4. Create Your First Test

Create `test/integration/default/default_test.rb`:

```ruby
# Test that the system is running
describe service('sshd') do
  it { should be_running }
end

# Test that a package is installed
describe package('curl') do
  it { should be_installed }
end

# Test that a file exists
describe file('/etc/hosts') do
  it { should exist }
  it { should be_file }
end
```

## 5. Run Your Tests

```bash
# Run full test cycle (destroy, create, converge, verify, destroy)
kitchen test

# Or step by step:
kitchen create
kitchen converge
kitchen verify
kitchen destroy
```

## That's It!

You're now running compliance tests with Cinc Auditor and Test Kitchen!

## Next Steps

- **Add more tests**: Learn about [InSpec resources](https://docs.chef.io/inspec/resources/)
- **Use remote profiles**: Add hardening tests from [Dev-Sec](https://dev-sec.io/)
- **Configure inputs**: Pass variables to your tests
- **Set up reporters**: Output results in multiple formats

See [INSTALL.md](INSTALL.md) for detailed configuration options.

## Example: Using a Remote Profile

```yaml
suites:
  - name: baseline
    verifier:
      inspec_tests:
        - name: linux-baseline
          url: https://github.com/dev-sec/linux-baseline
```

Run it:

```bash
kitchen verify baseline
```

## Getting Help

- Documentation: [README.md](README.md)
- Installation: [INSTALL.md](INSTALL.md)
- Issues: https://github.com/test-kitchen/kitchen-cinc-auditor/issues
