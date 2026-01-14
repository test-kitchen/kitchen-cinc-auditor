# Change Log

## [v1.0.0](https://github.com/test-kitchen/kitchen-cinc-auditor/tree/v1.0.0) (2026-01-14)

**Initial Release**

This is the initial release of kitchen-cinc-auditor, a fork of kitchen-inspec adapted to work with Cinc Auditor (the Community Distribution of Chef InSpec).

### What is kitchen-cinc-auditor?

kitchen-cinc-auditor is a Test Kitchen verifier plugin that enables compliance and security testing using Cinc Auditor, a free-as-in-freedom distribution of InSpec. It provides the same functionality as kitchen-inspec but uses Cinc Auditor instead of Chef InSpec, removing proprietary licensing requirements.

### Changes from kitchen-inspec

- **Gem name**: `kitchen-inspec` → `kitchen-cinc-auditor`
- **Verifier name**: `inspec` → `cinc_auditor` (in kitchen.yml)
- **Dependency**: Uses `cinc-auditor-bin` instead of `inspec-core`
- **Class name**: `Kitchen::Verifier::Inspec` → `Kitchen::Verifier::CincAuditor`
- **Repository**: Moved to https://github.com/test-kitchen/kitchen-cinc-auditor
- **Documentation**: Updated all references to Cinc Auditor

### Compatibility

- Maintains 100% API compatibility with kitchen-inspec
- Uses the same Inspec:: Ruby modules internally (provided by cinc-auditor-bin)
- Supports all InSpec profiles and tests without modification
- Compatible with Test Kitchen 2.7+ and 3.x
- Requires Ruby 2.7.0+

### Migration from kitchen-inspec

1. Replace `gem 'kitchen-inspec'` with `gem 'kitchen-cinc-auditor'` in your Gemfile
2. Install Cinc Auditor: `gem install cinc-auditor-bin`
3. Update your `.kitchen.yml`:
   ```yaml
   verifier:
     name: cinc_auditor  # Changed from 'inspec'
   ```
4. All other configuration remains the same

### Features

- All features from kitchen-inspec 3.1.0
- Support for InSpec/Cinc Auditor profiles (local, git, url, supermarket)
- Inputs and waivers support
- Multiple reporters (cli, json, junit, etc.)
- Plugin support
- Backend caching
- All Test Kitchen transports (SSH, WinRM, Docker, Local)

---

## Previous kitchen-inspec History

This project is based on kitchen-inspec. Below is the history from that project:

## [v3.1.0](https://github.com/inspec/kitchen-inspec/tree/v3.1.0) (2026-01-12)
- Modernize kitchen-inspec [#315](https://github.com/inspec/kitchen-inspec/pull/315) ([Stromweld](https://github.com/Stromweld))

## [v3.0.0](https://github.com/inspec/kitchen-inspec/tree/v3.0.0) (2025-03-27)
- CHEF-12879 Kitchen integration with InSpec 6  [#299](https://github.com/inspec/kitchen-inspec/pull/299) ([Nik08](https://github.com/Nik08))

For complete history, see the original kitchen-inspec repository at https://github.com/inspec/kitchen-inspec
