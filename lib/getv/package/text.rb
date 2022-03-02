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
        get(opts[:url]).split("\n")
      end
    end
  end
end
