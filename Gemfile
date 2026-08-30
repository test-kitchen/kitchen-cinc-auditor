# frozen_string_literal: true

source "https://rubygems.org"

source "https://rubygems.cinc.sh" do
  gem "cinc-auditor-bin"
end

gemspec development_group: :test
group :cookstyle do
  gem "cookstyle"
end

group :test do
  gem "rake"
  gem "rspec", ">= 3.0"
  gem "rubycritic", ">= 4.9"
end

group :docs do
  gem "yard"
end
