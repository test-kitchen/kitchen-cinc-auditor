# frozen_string_literal: true

require "bundler/gem_tasks"

task :spec do
  sh "mise run spec"
end

task :rubocop do
  sh "mise run rubocop"
end

task :syntax do
  sh "mise run syntax"
end

task :test do
  sh "mise run test"
end

desc "Generate the YARD documentation into doc/"
task :doc do
  sh "mise run doc"
end

desc "List anything in lib/ that is still undocumented"
task :doc_coverage do
  sh "mise run doc_coverage"
end

task default: :test
