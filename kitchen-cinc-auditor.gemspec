# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'kitchen/verifier/cinc_auditor_version'

metadata = {
  'bug_tracker_uri' => 'https://github.com/test-kitchen/kitchen-cinc-auditor/issues',
  'source_code_uri' => 'https://github.com/test-kitchen/kitchen-cinc-auditor'
}

Gem::Specification.new do |spec|
  spec.name = 'kitchen-cinc-auditor'
  spec.version = Kitchen::Verifier::CINC_AUDITOR_VERSION
  spec.license = 'Apache-2.0'
  spec.authors = ['CINC Project']
  spec.email = ['maintainers@cinc.sh']

  spec.summary = 'A Test Kitchen verifier for Cinc Auditor'
  spec.description = 'Runs Cinc Auditor profiles from Test Kitchen using the verifier behavior ' \
                     'expected by kitchen-inspec users.'
  spec.homepage = 'https://github.com/test-kitchen/kitchen-cinc-auditor'
  spec.metadata = metadata

  spec.files = `git ls-files -z`.split("\x0").grep(%r{\A(?:LICENSE|README\.md|lib/)})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.4'

  spec.add_dependency 'cinc-auditor-bin', '>= 7.1.7', '< 8.0'
  spec.add_dependency 'hashie', '>= 3.4', '< 6.0'
  spec.add_dependency 'test-kitchen', '>= 2.7', '< 5'
  spec.add_dependency 'train'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubycritic', '~> 4.9'
  spec.add_development_dependency 'simplecov', '~> 0.22'
end
