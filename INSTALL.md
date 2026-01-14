# Installation and Setup Guide for kitchen-cinc-auditor

This guide will help you install and configure kitchen-cinc-auditor for your Test Kitchen setup.

## Prerequisites

- Ruby 2.7.0 or higher
- Test Kitchen 2.7 or higher
- Cinc Auditor (the actual testing tool)

## Step 1: Install Cinc Auditor

First, you need to install Cinc Auditor itself. Choose one of these methods:

### Method 1: Via RubyGems (Recommended for Ruby projects)

```bash
gem install cinc-auditor-bin
```

### Method 2: Via Cinc Downloads

Download the appropriate package for your operating system from:
[https://cinc.sh/start/auditor/](https://cinc.sh/start/auditor/)

## Step 2: Install kitchen-cinc-auditor

### For Bundler Projects (Recommended)

Add to your `Gemfile`:

```ruby
gem 'kitchen-cinc-auditor'
```

Then run:

```bash
bundle install
```

### Direct Installation

```bash
gem install kitchen-cinc-auditor
```

## Step 3: Configure Test Kitchen

Update your `.kitchen.yml` to use the Cinc Auditor verifier:

```yaml
---
driver:
  name: vagrant  # or dokken, docker, etc.

provisioner:
  name: chef_zero  # or ansible, puppet, etc.

verifier:
  name: cinc_auditor

platforms:
  - name: ubuntu-24.04
  - name: centos-stream-9

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
```

## Step 4: Verify Installation

Check that everything is installed correctly:

```bash
# Check Cinc Auditor
cinc-auditor version

# Check Test Kitchen can find the verifier
kitchen diagnose | grep -A5 verifier
```

## Common Configuration Examples

### Using Remote InSpec Profiles

```yaml
verifier:
  name: cinc_auditor
  inspec_tests:
    - name: dev-sec/linux-baseline
      url: https://github.com/dev-sec/linux-baseline
```

### With Inputs

```yaml
verifier:
  name: cinc_auditor
  inputs:
    admin_user: ubuntu
    log_directory: /var/log/myapp
  inspec_tests:
    - test/integration/default
```

### With Multiple Reporters

```yaml
verifier:
  name: cinc_auditor
  reporter:
    - cli
    - junit:results/%{platform}_%{suite}_audit.xml
    - json:results/%{platform}_%{suite}_audit.json
```

### With Controls Filter

```yaml
verifier:
  name: cinc_auditor
  controls:
    - sshd-01
    - sshd-02
  inspec_tests:
    - name: dev-sec/ssh-baseline
```

## Troubleshooting

### "Cannot find gem 'cinc-auditor-bin'"

Make sure you've installed Cinc Auditor first:

```bash
gem install cinc-auditor-bin
```

### "undefined method for Kitchen::Verifier::CincAuditor"

Make sure your `.kitchen.yml` uses `cinc_auditor` not `inspec`:

```yaml
verifier:
  name: cinc_auditor  # Not 'inspec'
```

### Tests Not Found

Check your directory structure. By default, kitchen-cinc-auditor looks for tests in:

```
test/integration/<suite-name>/
```

You can customize this with:

```yaml
verifier:
  name: cinc_auditor
  test_base_path: custom/test/path
```

## Migrating from kitchen-inspec

1. Replace `gem 'kitchen-inspec'` with `gem 'kitchen-cinc-auditor'`
2. Install Cinc Auditor: `gem install cinc-auditor-bin`
3. Change `name: inspec` to `name: cinc_auditor` in `.kitchen.yml`
4. Run `bundle install`

All your existing tests, profiles, and configurations will work without changes!

## Next Steps

- Read the [README.md](README.md) for full configuration options
- Check out [Cinc Auditor documentation](https://cinc.sh/start/auditor/)
- Browse [InSpec resources](https://docs.chef.io/inspec/resources/) (fully compatible)
- Explore [Dev-Sec Hardening Profiles](https://dev-sec.io/)

## Getting Help

- Report issues: https://github.com/test-kitchen/kitchen-cinc-auditor/issues
- Cinc Project: https://cinc.sh/
- Test Kitchen docs: https://kitchen.ci/
