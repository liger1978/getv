# frozen_string_literal: true

module Getv
  class Package
    class GitHub
      # Getv::Package::GitHub::Commit class
      class Commit < Package::GitHub
        def initialize(name, opts = {})
          opts = {
            branch: 'master',
            select_search: '^((\d{8})(\d{6}),(([a-z\d]{7})(.*)))$',
            semantic_only: false
          }.merge(opts)
          opts = defaults.merge(opts)
          opts = github_defaults(name).merge(opts)
          super name, opts
        end

        private

        def retrieve_versions
          github.commits("#{opts[:owner]}/#{opts[:repo]}", opts[:branch]).map do |c|
            "#{DateTime.parse(c[:commit][:author][:date].to_s).strftime('%Y%m%d%H%M%S')},#{c[:sha]}"
          end
        end
      end
    end
  end
end
