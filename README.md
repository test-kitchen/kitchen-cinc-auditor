# kitchen-cinc-auditor

A [Test Kitchen](https://kitchen.ci/) verifier for [Cinc
Auditor](https://cinc.sh/start/auditor/), the community distribution of InSpec.
It runs compliance profiles and controls against your test instances after they
converge.

The verifier follows the `kitchen-inspec` interface wherever Cinc Auditor
exposes the same runtime API, so existing profiles and most existing verifier
configuration work unchanged.

## Requirements

- Ruby 3.1 or later
- `cinc-auditor-bin`, published on the CINC RubyGems server

## Installation

Cinc Auditor gems are published from the CINC RubyGems server, so that source
has to be included in your bundle:

```ruby
source "https://rubygems.org"

source "https://rubygems.cinc.sh" do
  gem "cinc-auditor-bin"
end

gem "kitchen-cinc-auditor"
```

Then:

```sh
bundle install
```

## Quick Start

Point the verifier at Cinc Auditor and put your controls in
`test/integration/<suite>`:

```yaml
---
driver:
  name: vagrant

provisioner:
  name: cinc_infra

verifier:
  name: cinc_auditor

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

With `test/integration/default/controls/example.rb` in place:

```sh
cinc kitchen verify
```

Or run the whole cycle:

```sh
cinc kitchen test
```

## Directory structure

By default, suite tests are loaded from `test/integration/<suite>`:

```text
test
  integration
    default
      controls
        example.rb
      inspec.yml
```

For cookbook-style layouts, `test/recipes` is preferred when it exists.

When a suite includes tests for more than one framework, put the Cinc Auditor
profile under `test/integration/<suite>/inspec`, matching the upstream
kitchen-inspec layout that Cinc Auditor supports:

```text
test
  integration
    default
      inspec
        controls
          example.rb
      serverspec
        example_spec.rb
```

## Configuration

All options below are set under the `verifier:` key in `kitchen.yml`, or per
suite under `suites[].verifier:`.

### Profiles and controls

| Option | Default | Description |
| --- | --- | --- |
| `inspec_tests` | `[]` | Profiles to run. Accepts local, URL, Git, Supermarket, and Compliance references, matching the profile targets `inspec exec` accepts. |
| `controls` | *all* | Array of control IDs to run, instead of every control in the profile. |
| `suite_name` | the suite name | Name of the suite directory searched under the test base path. |

### Inputs and waivers

| Option | Default | Description |
| --- | --- | --- |
| `inputs` | *unset* | Hash of inline inputs passed to the profile. |
| `input_files` | *unset* | Array of YAML files containing inputs. |
| `waiver_files` | *unset* | Array of waiver files applied to the run. |
| `cache_inputs` | *runtime default* | Cache inputs in the Cinc Auditor input registry. |

Legacy `attributes` and `attrs` aliases are no longer supported; use `inputs`
and `input_files`.

### Output and reporting

`reporter` entries and `output` support `%{platform}` and `%{suite}`
replacements.

| Option | Default | Description |
| --- | --- | --- |
| `reporter` | *runtime default* | Array of reporters, e.g. `cli`, or `junit:path/results/%{platform}.xml`. |
| `output` | *unset* | Path to write results to. |
| `format` | *unset* | Output format passed to the runner. |
| `color` | `true` | Colourise the output. |
| `profiles_path` | *unset* | Path used to resolve profile dependencies. |

### Connection

Host and port normally come from Test Kitchen state and only need setting to
override it.

| Transport | `transport: name:` | Cinc Auditor backend |
| --- | --- | --- |
| SSH | `ssh` | `ssh` |
| WinRM | `winrm` | `winrm` |
| Exec | `exec` | `local` |
| [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) | `docker` | `docker` |
| [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) | `dokken` | `docker` |
| [kitchen-docker_cli](https://github.com/mfuchs/kitchen-docker_cli) | `docker_cli` | `docker` |

Any other transport raises `Verifier cinc_auditor does not support the <name>
Transport`.

| Option | Default | Description |
| --- | --- | --- |
| `host` | *from Test Kitchen state* | Host to connect to. |
| `port` | *from Test Kitchen state* | Port to connect to. |
| `sudo` | *transport default* | Run the profile under sudo. |
| `sudo_command` | *transport default* | Command used to elevate, e.g. `sudo -E`. |
| `sudo_options` | *transport default* | Extra options passed to sudo, e.g. `-H`. |
| `proxy_command` | *unset* | SSH proxy command, e.g. `ssh gateway -W %h:%p`. |
| `forward_agent` | *transport default* | Forward the SSH agent to the instance. |

### Plugins and caching

| Option | Default | Description |
| --- | --- | --- |
| `load_plugins` | `true` | Load Cinc Auditor plugins before config validation. |
| `plugin_config` | `{}` | Plugin configuration, merged when the installed runtime supports it. |
| `backend_cache` | `true` | Cache backend command and file results during a run. |

Chef license key settings are intentionally not forwarded. Cinc Auditor does not
need them.

## Examples

### Profiles from several sources

```yaml
suites:
  - name: default
    verifier:
      inspec_tests:
        - path: test/integration/default
        - url: https://example.test/profile.zip
        - git: https://github.com/dev-sec/tests-ssh-hardening.git
        - name: hardening/ssh-hardening
        - compliance: base/ssh
      controls:
        - sshd-46
```

When both local suite tests and configured profiles exist, the local suite tests
are added first and the configured `inspec_tests` afterwards. Duplicate local
paths are deduplicated.

### Inputs and waivers

```yaml
verifier:
  name: cinc_auditor
  inputs:
    user: bob
    debug: false
  input_files:
    - test/integration/profile-inputs.yml
  waiver_files:
    - test/integration/waivers.yml
```

### JUnit output for CI

```yaml
verifier:
  name: cinc_auditor
  reporter:
    - cli
    - junit:path/to/results/%{platform}_%{suite}_cinc_auditor.xml
  output: /tmp/%{platform}_%{suite}.json
  format: json
```

### Running over sudo, through a bastion

```yaml
verifier:
  name: cinc_auditor
  sudo: true
  sudo_command: sudo -E
  sudo_options: -H
  proxy_command: ssh gateway -W %h:%p
  forward_agent: true
```

### Plugins

```yaml
verifier:
  name: cinc_auditor
  load_plugins: true
  plugin_config:
    example_plugin:
      example_setting: value
```

### Disabling caching

```yaml
verifier:
  name: cinc_auditor
  cache_inputs: false
  backend_cache: false
```

## Using with Chef

This verifier runs Cinc Auditor, and is the Cinc counterpart to
`kitchen-inspec`.

If you use [Chef Workstation](https://www.chef.io/downloads/tools/workstation)
rather than [Cinc Workstation](https://cinc.sh/start/workstation/), you can
still use this verifier — run `kitchen` instead of `cinc kitchen`, and pair it
with whichever provisioner you use:

```yaml
provisioner:
  name: chef_infra

verifier:
  name: cinc_auditor
```

If you would rather run InSpec itself, use `kitchen-inspec` with `verifier:
name: inspec`. Profiles are compatible either way, and the verifier options
above are modelled on the same interface.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/test-kitchen/kitchen-cinc-auditor). See
[CONTRIBUTING.md](CONTRIBUTING.md) for development setup, how to run the checks,
and the release process.

## License compatibility

This verifier is Apache-2.0 licensed. `kitchen-inspec` is also Apache-2.0
licensed and was used as a behavioural compatibility reference for Test Kitchen
verifier options and profile discovery.
