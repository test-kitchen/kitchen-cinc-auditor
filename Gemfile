source "https://rubygems.org"
gemspec

group :guard do
  gem "guard-rspec",    require: nil
  gem "guard-rubocop",  require: nil
end

group :test do
  gem "minitest", ">= 5.5", "< 6.0"  # minitest 6+ requires Ruby 3.2+
  gem "rake", ">= 13.0", "< 14.0"
  gem "cookstyle", ">= 8.0", "< 9.0"
  gem "concurrent-ruby", ">= 1.0", "< 2.0"
  gem "rspec"
  gem "simplecov", ">= 0.12", "< 1.0"
  gem "countloc", ">= 0.4", "< 1.0"
end

group :integration do
  # chef-cli has syslog issues on macOS, skip for now
  # gem "chef-cli"
  # Use inspec-core for testing until cinc-auditor-bin is available
  # In production, users will install cinc-auditor-bin separately
  gem "inspec-core", ">= 5.0", "< 8.0"
  # kitchen-dokken requires Ruby 3.2+, skip if on older Ruby
  gem "kitchen-dokken" if RUBY_VERSION >= '3.2.0'
end

group :tools do
  gem "pry", ">= 0.10", "< 1.0"
end
