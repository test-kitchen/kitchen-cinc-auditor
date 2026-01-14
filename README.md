# Kitchen::CincAuditor - A Test Kitchen Verifier for Cinc Auditor

- **Project State: Active**
- **Issues Response SLA: 3 business days**
- **Pull Request Response SLA: 3 business days**

For more information on project states and SLAs, see [this documentation](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md).

[![Gem Version](https://badge.fury.io/rb/kitchen-cinc-auditor.svg)](https://badge.fury.io/rb/kitchen-cinc-auditor)

This is the kitchen verifier for [Cinc Auditor](https://cinc.sh/), the Community Distribution of Chef InSpec. 

Cinc Auditor is a free-as-in-freedom distribution of InSpec, providing compliance and security testing without proprietary Chef licensing requirements.

## Installation

### Prerequisites

You must have Cinc Auditor installed. Install it with:

```shell
gem install cinc-auditor-bin
```

Or download from [https://cinc.sh/start/auditor/](https://cinc.sh/start/auditor/)

### Installing kitchen-cinc-auditor

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-cinc-auditor'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install kitchen-cinc-auditor
```

## Usage

In your kitchen.yml include

```yaml
verifier:
  name: cinc_auditor
```

Optionally specify sudo and sudo_command

```yaml
verifier:
  name: cinc_auditor
  sudo: true
  sudo_command: 'skittles'
```

You can also specify the host and port to be used by Cinc Auditor when targeting the node. Otherwise, it defaults to the hostname and port used by kitchen for converging.

```yaml
verifier:
  name: cinc_auditor
  host: 192.168.56.40
  port: 22
```

### Expected Directory Structure

By default `kitchen-cinc-auditor` expects test to be in `test/integration/%suite%` directory structure (we use Chef as provisioner here):

```text
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── web_spec.rb
```

#### Directory Structure with complete profile

A complete profile is used here, including a custom Cinc Auditor resource named `gordon_config`:

```text
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            ├── controls
            │   └── gordon.rb
            ├── inspec.yml
            └── libraries
                └── gordon_config.rb
```

#### Combination with other testing frameworks

If you need support with other testing frameworks, we recommend to place the tests in `test/integration/%suite%/cinc-auditor`:

```text
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── cinc-auditor
                └── web_spec.rb
```

### Specifying the Sudo Command

You can enable/disable sudo and set your own custom sudo command.

```yaml
verifier:
  name: cinc_auditor
  sudo: true
  sudo_command: 'skittles'
```

### Custom Host Settings

You can also specify the host, port, and proxy settings to be used by Cinc Auditor when targeting the node. Otherwise, it defaults to the hostname and port used by kitchen for converging.

```yaml
verifier:
  name: cinc_auditor
  host: 192.168.56.40
  port: 22
  proxy_command: ssh user@1.2.3.4 -W %h:%p
```

### Custom Outputs

If you want to customize the output file per platform or test suite you can use template format for your output variable. Current flags supported:

- _%{platform}_
- _%{suite}_

```yaml
verifier:
  name: cinc_auditor
  reporter:
    - cli
    - junit:path/to/results/%{platform}_%{suite}_inspec.xml
```

You can also decide to only run specific controls, instead of a full profile. This is done by specifying a list of controls:

```yaml
suites:
  - name: supermarket
    run_list:
      - recipe[apt]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - name: dev-sec/ssh-baseline
      controls:
        - sshd-46
    ...
```

### Use remote Cinc Auditor profiles

In case you want to reuse tests across multiple cookbooks, they should become an extra artifact independent of a Chef cookbook, called InSpec/Cinc Auditor profiles. Those can be easily added to existing local tests as demonstrated in previous sections. To include remote profiles, adapt the `verifier` attributes in `kitchen.yml`

```yaml
suites:
  - name: default
    verifier:
      inspec_tests:
        - name: ssh-hardening
          url: https://github.com/dev-sec/tests-ssh-hardening
```

`inspec_tests` accepts all values that `cinc-auditor exec profile` would expect. We support:

- local directory eg. `path: /path/to/profile`
- github url `git: https://github.com/dev-sec/tests-ssh-hardening.git`
- Chef Supermarket `name: hardening/ssh-hardening` # defaults to supermarket (list all available profiles with `cinc-auditor supermarket profiles`)
- Chef Compliance `name: ssh` `compliance: base/ssh`

The following example illustrates the usage in a `kitchen.yml`

```yaml
suites:
  - name: contains_inspec
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
      - recipe[os-hardening]
    verifier:
      inspec_tests:
        - path: path/to/some/local/tests
        - name: ssh-hardening
          url: https://github.com/dev-sec/tests-ssh-hardening/archive/master.zip
        - name: os-hardening
          git: https://github.com/dev-sec/tests-os-hardening.git
  - name: supermarket
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - name: hardening/ssh-hardening  # name only defaults to supermarket
        - name: ssh-supermarket  # alternatively, you can explicitly specify that the profile is from supermarket in this way
          supermarket: hardening/ssh-hardening
          supermarket_url: http://supermarket.example.com
  # before you are able to use the compliance plugin, you need to run
  # insecure is only required if you use self-signed certificates
  # $ cinc-auditor compliance login https://compliance.test --user admin --insecure --token ''
  - name: compliance
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - name: ssh
          compliance: base/ssh
```

### Use inputs with your Cinc Auditor profiles

To run a profile with inputs defined inline, you can adapt your `kitchen.yml`:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      inputs:
        user: bob
        password: secret
```

You can also define your inputs in external files. Adapt your `kitchen.yml` to point to those files:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      input_files:
        - test/integration/profile-attribute.yml
```

## Use waivers with your Cinc Auditor profiles

You can define your [waivers](https://docs.chef.io/inspec/waivers/) in external files:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      input_files:
        - test/integration/profile-attribute.yml
      waiver_files:
        - test/integration/control-waiver-01.yml
```

### Use Cinc Auditor plugins

By default, the verifier loads Cinc Auditor plugins such as additional Reporter or Input plugins. This adds a small delay as the system scans for plugins. If you know you are not using special Reporters or Inputs, you can disable plugin loading:

```yaml
    verifier:
      load_plugins: false
```

Some Cinc Auditor plugins allow further configuration. You can supply these settings as well with Cinc Auditor 4.26 or newer:

```yaml
    verifier:
      plugin_config:
        example_plugin_name:
          example_setting: "Example value"
```

When using Input plugins, please be aware that input values get cached between suites. If you want to re-evaluate these values for every suite, you can deactivate the cache:

```yaml
    verifier:
      cache_inputs: false
```

### Cinc Auditor Backend Cache

 Cinc Auditor uses a cache when executing commands and accessing files on the remote target. The cache is enabled by default. To disable the cache:

 ```yaml
     verifier:
       backend_cache: false
 ```

### Configure Chef License Key and Licensing Service URL for Cinc Auditor version 6 or higher

To configure Chef License Key for Cinc Auditor, modify your `kitchen.yml` in the following way:

```yaml
    verifier:
      chef_license_key: LICENSE_KEY_VALUE
```

Or

It could also be configured by setting environment variable `CHEF_LICENSE_KEY` with the license key string.

Additionally, If you are using Cinc Auditor with Local Licensing Service, you can configure `chef_license_server` by providing the Licensing Service URL.

```yaml
    verifier:
      chef_license_key: LICENSE_KEY_VALUE
      chef_license_server: https://test-local-licensing-service-url
```

Or

For avoiding a single point of failure, it is possible to set up multiple local licensing services. To configure them for Cinc Auditor, modify your `kitchen.yml` as follows:

```yaml
    verifier:
      chef_license_key: LICENSE_KEY_VALUE
      chef_license_server:
        - https://test-local-licensing-service-url-1
        - https://test-local-licensing-service-url-2
        - https://test-local-licensing-service-url-3
```

It could also be configured by setting environment variable `CHEF_LICENSE_SERVER` with the Licensing Service URL(s).

## Migrating from kitchen-inspec

If you're migrating from kitchen-inspec, follow these steps:

1. **Update your Gemfile**:
   ```ruby
   # Remove:
   # gem 'kitchen-inspec'
   
   # Add:
   gem 'kitchen-cinc-auditor'
   ```

2. **Install Cinc Auditor**:
   ```shell
   gem install cinc-auditor-bin
   ```

3. **Update your `.kitchen.yml`**:
   ```yaml
   verifier:
     name: cinc_auditor  # Changed from 'inspec'
     # All other configuration stays the same
   ```

4. **Run bundle install**:
   ```shell
   bundle install
   ```

That's it! All your existing InSpec profiles, tests, and configuration will work without modification.

### Why Cinc Auditor?

- **Free as in Freedom**: No proprietary licensing or commercial restrictions
- **Community-Driven**: Maintained by the Cinc project community
- **100% Compatible**: Drop-in replacement for InSpec, same Ruby API
- **No Vendor Lock-in**: Open source all the way down

## About Cinc

Cinc is a free-as-in-freedom community distribution of Chef tools. It removes all Chef trademarks and provides fully open source alternatives. Cinc Auditor is the community distribution of InSpec, providing the same powerful compliance testing without proprietary requirements.

Learn more at [https://cinc.sh/](https://cinc.sh/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/test-kitchen/kitchen-cinc-auditor>.

## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/test-kitchen/kitchen-cinc-auditor/blob/master/LICENSE
