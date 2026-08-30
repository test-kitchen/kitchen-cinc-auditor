# Contributing to kitchen-cinc-auditor

Thanks for your interest in improving kitchen-cinc-auditor. Bug reports, feature requests, and pull requests are all welcome.

## Reporting issues

Report bugs and request features on the [issue tracker](https://github.com/test-kitchen/kitchen-cinc-auditor/issues). For bugs, please include:

- the version of kitchen-cinc-auditor, Test Kitchen, and `cinc-auditor-bin` you are using
- your `kitchen.yml` verifier block
- the profile layout, since profile discovery depends on it
- the output of the failing command, ideally with `-l debug`

## Development setup

```sh
git clone https://github.com/test-kitchen/kitchen-cinc-auditor.git
cd kitchen-cinc-auditor
bundle install
```

The gem supports Ruby 3.1 or later, and CI runs the unit tests across the whole
supported range.

## Running the checks

```sh
bundle exec rake                  # style and unit tests -- what CI runs
bundle exec rake test             # unit tests only (alias: rake unit)
bundle exec rake style            # Cookstyle with the Chefstyle rules
bundle exec rake quality          # RubyCritic, minimum score 70
```

To run a single spec file, or a single example:

```sh
bundle exec rspec spec/kitchen/verifier/cinc_auditor/transports_spec.rb
bundle exec rspec spec/kitchen/verifier/cinc_auditor/transports_spec.rb:42
```

Cookstyle must be run with the `--chefstyle` flag. A bare `cookstyle` run
applies the cookbook cops, which do not apply to a gem:

```sh
bundle exec cookstyle --chefstyle
```

The unit tests never talk to a Cinc Auditor runtime or a real instance. The
verifier turns Test Kitchen configuration and transport state into a runner
option hash, and that is all pure Ruby, so the specs stub the runtime and
assert on the options.

RubyCritic enforces a minimum score of 70, so a change that significantly
increases complexity can fail the build even when the tests pass.

## Documentation

Public API documentation is written as YARD comments in `lib/`:

```sh
bundle exec rake doc            # generate doc/
bundle exec rake doc_coverage   # list anything still undocumented
```

## Submitting changes

1. Fork the repository.
2. Create a feature branch off `main`.
3. Make your change, adding or updating specs to cover it.
4. Make sure `bundle exec rake` passes.
5. Use [conventional commits](https://www.conventionalcommits.org/) — release
   automation depends on them, see below.
6. Push the branch to your fork and open a pull request.

Please keep pull requests focused on a single change — it makes review much
faster. Update the documentation in `README.md` when you add or change a
verifier option.

## Release process

Releases are managed by [release-please](https://github.com/googleapis/release-please).

Conventional commits merged to `main` update a release pull request. Merging
that pull request updates `CHANGELOG.md`, bumps
`lib/kitchen/verifier/cinc_auditor_version.rb`, creates a GitHub release, and
publishes the tagged gem.

Publishing uses `actionshub/publish-ruby-gem` with Ruby 3.4. It needs:

- a `rubygems` environment with a `RUBYGEMS_AUTH_TOKEN` secret holding a
  RubyGems.org token with push access for `kitchen-cinc-auditor`
- optionally `RELEASE_PLEASE_TOKEN`, if release-please pull requests should
  trigger ordinary CI checks; without it the workflow falls back to
  `GITHUB_TOKEN`

## License compatibility

This verifier is Apache-2.0 licensed. `kitchen-inspec` is also Apache-2.0
licensed and was used as a behavioural compatibility reference for Test Kitchen
verifier options and profile discovery.
