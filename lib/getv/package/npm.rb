# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Npm class
    class Npm < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { npm: name[/node(js)?-(.*)/, 2] || name }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        require 'json'
        retries ||= 0
        JSON.parse(get("https://registry.npmjs.org/#{opts[:npm]}"))['versions'].keys
      rescue StandardError
        retry if (retries += 1) < 4
      end
    end
  end
end
