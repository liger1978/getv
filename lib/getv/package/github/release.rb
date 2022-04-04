# frozen_string_literal: true

module Getv
  class Package
    class GitHub
      # Getv::Package::GitHub::Release class
      class Release < Package::GitHub
        def initialize(name, opts = {})
          opts = defaults.merge(opts)
          opts = github_defaults(name).merge(opts)
          super name, opts
        end

        private

        def retrieve_versions
          retries ||= 0
          github.releases("#{opts[:owner]}/#{opts[:repo]}").map(&:tag_name)
        rescue StandardError
          retry if (retries += 1) < 4
        end
      end
    end
  end
end
