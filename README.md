# kitchen-cinc-auditor

A Test Kitchen verifier for Cinc Auditor.

## Installation

Cinc Auditor gems are published from the CINC RubyGems server, so include that source in your bundle:

```ruby
source "https://rubygems.org"

source "https://rubygems.cinc.sh" do
  gem "cinc-auditor-bin"
end

gem "kitchen-cinc-auditor"
```

## Usage

```yaml
verifier:
  name: cinc_auditor
```

The verifier follows the `kitchen-inspec` interface where Cinc Auditor exposes the same runtime API.

This gem targets Ruby 3.4 or newer, matching the Ruby line used by Chef Workstation 26.

## Directory structure

By default, suite tests are loaded from `test/integration/<suite>`.

```text
test
  integration
    default
      controls
        example.rb
      inspec.yml
```

For cookbook-style layouts, `test/recipes` is preferred when it exists. When a suite includes tests for other frameworks, place the Cinc Auditor profile under `test/integration/<suite>/inspec`.

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

## Connection options

SSH, WinRM, Exec, Dokken, and Docker CLI transports are supported. Host and port normally come from Test Kitchen state, but can be overridden:

```yaml
verifier:
  name: cinc_auditor
  host: 192.168.56.40
  port: 22
```

SSH sudo, proxy, and forwarding settings are passed through to the Cinc Auditor runner:

```yaml
verifier:
  name: cinc_auditor
  sudo: true
  sudo_command: sudo -E
  sudo_options: -H
  proxy_command: ssh gateway -W %h:%p
  forward_agent: true
```

## Profiles and controls

Local, URL, Git, Supermarket, and Compliance profile references are accepted through `inspec_tests`, matching the profile target shapes accepted by `inspec exec`.

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

If both local suite tests and configured profiles exist, local suite tests are added first and configured `inspec_tests` are added afterward. Duplicate local paths are deduplicated.

## Inputs and waivers

Inline inputs and input files are passed to Cinc Auditor using the current runtime option names. Legacy `attributes` and `attrs` aliases are no longer supported; use `inputs` and `input_files`.

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

## Output and reporting

Reporter and output paths support `%{platform}` and `%{suite}` replacements.

```yaml
verifier:
  name: cinc_auditor
  reporter:
    - cli
    - junit:path/to/results/%{platform}_%{suite}_cinc_auditor.xml
  output: /tmp/%{platform}_%{suite}.json
  format: json
  profiles_path: /tmp/cinc-auditor-profiles
```

## Plugins and caching

Plugins are loaded by default before Cinc Auditor config validation. Plugin config is merged when the installed Cinc Auditor runtime supports it.

```yaml
verifier:
  name: cinc_auditor
  load_plugins: true
  plugin_config:
    example_plugin:
      example_setting: value
```

Input caching follows the compatible Cinc Auditor input registry behavior:

```yaml
verifier:
  name: cinc_auditor
  cache_inputs: false
```

Backend command/file caching is enabled by default and can be disabled:

```yaml
verifier:
  name: cinc_auditor
  backend_cache: false
```

Chef license key settings are intentionally not forwarded. Cinc Auditor does not need them.

## Development

Run the full local check suite through mise:

```shell
mise run test
```

That task runs the RSpec suite, RuboCop, a syntax check for the verifier entrypoint, and RubyCritic. The local and CI harnesses target Ruby 3.4 to match Chef Workstation 26.

The spec task writes SimpleCov output to `coverage/`, including `coverage/.resultset.json`. The RubyCritic task consumes that coverage data and enforces a minimum score of 70:

```shell
mise run rubycritic
```

## Release process

Releases are managed by release-please. Conventional commits merged to `main` update a release PR; merging that PR updates `CHANGELOG.md`, bumps `lib/kitchen/verifier/cinc_auditor_version.rb`, creates a GitHub release, and publishes the tagged gem.

Publishing uses `actionshub/publish-ruby-gem` with Ruby 3.4. Configure a `rubygems` environment with a `RUBYGEMS_AUTH_TOKEN` secret that has RubyGems.org push access for `kitchen-cinc-auditor`. Add `RELEASE_PLEASE_TOKEN` if release-please PRs should trigger ordinary CI checks; otherwise the workflow falls back to `GITHUB_TOKEN`.

## License compatibility

This verifier is Apache-2.0 licensed. `kitchen-inspec` is also Apache-2.0 licensed and was used as a behavioral compatibility reference for Test Kitchen verifier options and profile discovery.
