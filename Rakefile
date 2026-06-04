# frozen_string_literal: true

require 'bundler/gem_tasks'

task :spec do
  sh 'mise run spec'
end

task :rubocop do
  sh 'mise run rubocop'
end

task :syntax do
  sh 'mise run syntax'
end

task :test do
  sh 'mise run test'
end

task default: :test
