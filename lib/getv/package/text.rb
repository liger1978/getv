# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Text class
    class Text < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { url: nil, user: nil, password: nil }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        retries ||= 0
        get(opts[:url]).split("\n")
      rescue StandardError
        retry if (retries += 1) < 4
      end
    end
  end
end
