# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::GitHub class
    class GitHub < Package
      def initialize(name, opts = {})
        super name, opts
      end

      private

      def github_defaults(name)
        case name.count('/')
        when 1
          { owner: name.split('/')[0], repo: name.split('/')[1], token: nil }
        else
          { owner: name, repo: name, token: nil }
        end
      end

      def github # rubocop:disable Metrics/MethodLength
        require 'octokit'
        if opts[:token]
          github = Octokit::Client.new(access_token: opts[:token])
          user = github.user
          user.login
        else
          github = Octokit::Client.new
        end
        github.auto_paginate = true
        github.proxy = opts[:proxy]
        github
      end
    end
  end
end
