# frozen_string_literal: true

module Getv
  class Package
    class GitHub
      # Getv::Package::GitHub::Tag class
      class Tag < Package::GitHub
        def initialize(name, opts = {})
          opts = defaults.merge(opts)
          opts = github_defaults(name).merge(opts)
          super name, opts
        end

        private

        def retrieve_versions
          github.tags("#{opts[:owner]}/#{opts[:repo]}").map { |t| t[:name] }
        end
      end
    end
  end
end
