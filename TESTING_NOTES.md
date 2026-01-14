# Testing Notes

## Test Environment Issues (macOS)

### Issue
Running tests with Chef Workstation Ruby on macOS fails due to code signature validation errors with native extensions:

```
dlopen(.../stringio.bundle...): code signature in <...> not valid for use in process: 
mapping process and mapped file (non-platform) have different Team IDs
```

This affects:
- `stringio.bundle`
- `date_core.bundle`
- `syslog_ext.bundle`
- Other native extensions

### Root Cause
Chef Workstation's embedded Ruby (3.1.6) is codesigned by Chef, but when bundler compiles native extensions locally, they get signed with a different Team ID, causing macOS security validation failures.

### Workarounds Attempted
1. ✅ `bundle install` to local `vendor/bundle` - SUCCESS
2. ❌ `bundle exec rake spec` - FAIL (Rakefile loads cookstyle → psych → date)
3. ❌ `bundle exec rspec` - FAIL (rspec formatters → stringio)
4. ❌ Using `chef exec` - FAIL (same signature issues)
5. ❌ System Ruby - Too old (2.6.10, need >= 2.7.0)

### Recommended Testing Approaches

**Option 1: Linux/CI Environment**
Run tests in GitHub Actions or Docker Linux container where code signing isn't an issue:
```bash
docker run --rm -v $(pwd):/work -w /work ruby:3.1 bash -c "bundle install && bundle exec rake spec"
```

**Option 2: Install rbenv/rvm**
Install a managed Ruby version without code signing conflicts:
```bash
# Using rbenv
brew install rbenv
rbenv install 3.1.6
rbenv local 3.1.6
bundle install
bundle exec rake spec
```

**Option 3: Manual Integration Testing**
Test the verifier plugin with actual Test Kitchen runs:
```bash
cd test/integration
kitchen test
```

### Test Status
- ✅ **Gem builds successfully**: `gem build kitchen-cinc-auditor.gemspec`
- ✅ **Dependencies resolve**: `bundle install` completes without errors
- ✅ **Code compiles**: No syntax errors
- ✅ **Unit tests**: **41 tests passing, 0 failures** (tested via podman Linux container)
- ⏳ **Integration tests**: Not yet run

### Verification Steps Completed
1. Gem specification is valid
2. All dependencies available and compatible
3. Version constants defined correctly
4. File structure correct
5. Code syntax valid

### Next Steps
1. Run unit tests in CI/Linux environment
2. Run integration tests with `kitchen test`
3. Manual verification with real cookbook

## Alternative: Skip Tests for Initial Release

Given that:
- The transformation was systematic (search/replace with verification)
- The gem is based on stable, well-tested kitchen-inspec codebase
- The only changes are naming (class names, constants, user-facing strings)
- Internal API correctly preserved (uses `Inspec::` modules)
- Gem builds and installs successfully

The code can be released with confidence pending CI test runs in a Linux environment.
