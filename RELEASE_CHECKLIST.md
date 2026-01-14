# Release Checklist for kitchen-cinc-auditor v1.0.0

## Pre-Release Tasks

- [x] Code transformation complete (InSpec → Cinc Auditor)
- [x] All files renamed appropriately
- [x] Gemspec updated with correct dependencies
- [x] Version updated to 1.0.0
- [x] CHANGELOG.md created with initial release notes
- [x] README.md updated with Cinc Auditor references
- [x] INSTALL.md created with setup instructions
- [x] Gem successfully builds (`kitchen-cinc-auditor-1.0.0.gem`)

## Testing Tasks (To Do)

- [ ] Run unit tests: `bundle exec rake spec`
- [ ] Run linting: `bundle exec rake lint`
- [ ] Test with a real cookbook and .kitchen.yml
- [ ] Verify all transport types work (SSH, WinRM, Docker, Local)
- [ ] Test with remote InSpec profiles (git, url, supermarket)
- [ ] Test with inputs and waivers
- [ ] Test with different reporters (cli, json, junit)
- [ ] Test migration from kitchen-inspec

## Documentation Tasks (To Do)

- [ ] Review and update .github/copilot-instructions.md
- [ ] Create or update GitHub issue templates
- [ ] Create pull request template
- [ ] Add CONTRIBUTING.md if not present
- [ ] Add CODE_OF_CONDUCT.md if not present
- [ ] Update MAINTAINERS.md with new project info

## Repository Setup Tasks (To Do)

- [ ] Create GitHub repository: test-kitchen/kitchen-cinc-auditor
- [ ] Set up branch protection rules
- [ ] Configure GitHub Actions/CI (if not using Expeditor)
- [ ] Add repository topics/tags (ruby, test-kitchen, cinc, inspec, compliance)
- [ ] Set up issue labels
- [ ] Configure dependabot or renovate
- [ ] Add repository description and website link

## Release Tasks (To Do)

- [ ] Commit all changes: `git commit -m "Initial release of kitchen-cinc-auditor v1.0.0"`
- [ ] Tag the release: `git tag -a v1.0.0 -m "Release v1.0.0"`
- [ ] Push to GitHub: `git push origin main --tags`
- [ ] Create GitHub Release with release notes
- [ ] Publish gem to RubyGems: `gem push kitchen-cinc-auditor-1.0.0.gem`
- [ ] Announce on relevant channels (Chef Slack, Cinc community, etc.)

## Post-Release Tasks (To Do)

- [ ] Monitor for issues and feedback
- [ ] Update any related documentation
- [ ] Create announcement blog post or tweet
- [ ] Add to Cinc project website/documentation
- [ ] Update Test Kitchen plugin directory (if exists)

## Important Notes

### Dependency on cinc-auditor-bin

**CRITICAL**: The gem depends on `cinc-auditor-bin` which may not be published yet to RubyGems. Before releasing:

1. Check if `cinc-auditor-bin` is available on RubyGems
2. If not, coordinate with Cinc project maintainers
3. May need to temporarily use `inspec-core` as a development dependency
4. Update gemspec once `cinc-auditor-bin` is available

### Ruby Version Requirement

The gem now requires Ruby 2.7.0+ (updated from 2.3.0) to support modern development tools. This matches InSpec's requirements.

### API Compatibility

Remember: kitchen-cinc-auditor uses `Inspec::` Ruby modules internally because Cinc Auditor maintains API compatibility. This is correct and expected.

### Testing with InSpec

During development and testing, you can use `inspec-core` as a stand-in for `cinc-auditor-bin` since they provide the same API. Just make sure the final gem depends on `cinc-auditor-bin`.

## Files Generated

- [x] kitchen-cinc-auditor-1.0.0.gem (built successfully)
- [x] CHANGELOG.md (new)
- [x] INSTALL.md (new)
- [x] README.md (updated)
- [x] All source files renamed and updated

## Next Immediate Steps

1. Set up Ruby 3.x environment for testing
2. Run full test suite
3. Create GitHub repository
4. Coordinate with Cinc project about cinc-auditor-bin availability
5. Perform manual integration test with real cookbook
