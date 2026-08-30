# frozen_string_literal: true

source "https://rubygems.org"

source "https://rubygems.cinc.sh" do
  gem "cinc-auditor-bin"
end

gemspec development_group: :test

# Integration testing. `kitchen test` drives the verifier through a real Test
# Kitchen run against a container. The unit tests do not need any of this, so
# CI installs the unit-test matrix with BUNDLE_WITHOUT=development.
group :development do
  gem "kitchen-docker"
end

group :cookstyle do
  gem "cookstyle"
end

group :test do
  gem "rake"
  gem "rspec", ">= 3.0"
  gem "rubycritic", ">= 4.9"
  gem "simplecov", ">= 0.22"
end

group :docs do
  gem "yard"
end
