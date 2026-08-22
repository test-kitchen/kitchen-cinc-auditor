# Contributing to kitchen-cinc-auditor

Thanks for your interest in improving kitchen-cinc-auditor. Bug reports, feature requests, and pull requests are all welcome.

## Reporting issues

Report bugs and request features on the [issue tracker](https://github.com/test-kitchen/kitchen-cinc-auditor/issues). For bugs, please include:

- the version of kitchen-cinc-auditor, Test Kitchen, and `cinc-auditor-bin` you are using
- your `kitchen.yml` verifier block
- the profile layout, since profile discovery depends on it
- the output of the failing command, ideally with `-l debug`

## Development setup

The project uses [mise](https://mise.jdx.dev/) to pin the toolchain. The
development toolchain targets **Ruby 3.4**, matching the Ruby line used by Chef
Workstation 26, while the gem itself supports Ruby 3.1 or later at runtime.

```sh
git clone https://github.com/test-kitchen/kitchen-cinc-auditor.git
cd kitchen-cinc-auditor
mise install
bundle install
```

## Running the checks

Run the full local check suite:

```sh
mise run test
```

That runs the RSpec suite, RuboCop, a syntax check of the verifier entrypoint,
and RubyCritic. The individual tasks are:

```sh
mise run spec        # RSpec
mise run rubocop     # RuboCop
mise run syntax      # ruby -c on the verifier entrypoint
mise run rubycritic  # RubyCritic, minimum score 70
```

CI and the release workflow run these as separate jobs, so RSpec, RuboCop, and
the syntax check run in parallel. RubyCritic runs after RSpec because it
consumes the SimpleCov result artifact.

The spec task writes SimpleCov output to `coverage/`, including
`coverage/.resultset.json`. RubyCritic reads that coverage data and enforces a
minimum score of 70, so a change that significantly increases complexity can
fail the build even when the tests pass.

## Submitting changes

1. Fork the repository.
2. Create a feature branch off `main`.
3. Make your change, adding or updating specs to cover it.
4. Make sure `mise run test` passes.
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
