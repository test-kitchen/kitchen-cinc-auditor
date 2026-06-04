# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :line

  add_filter '/spec/'
  add_group 'Library', 'lib'
end

require 'tmpdir'
require 'fileutils'
require 'logger'
require 'stringio'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |file| require file }
