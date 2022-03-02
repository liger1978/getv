# frozen_string_literal: true

require 'getv/version'
require 'getv/package'
require 'getv/package/docker'
require 'getv/package/gem'
require 'getv/package/github'
require 'getv/package/github/commit'
require 'getv/package/github/release'
require 'getv/package/github/tag'
require 'getv/package/helm'
require 'getv/package/npm'
require 'getv/package/pypi'
require 'getv/package/text'
require 'getv/package/xml'

module Getv
  class Error < StandardError; end
  # Your code goes here...
end
