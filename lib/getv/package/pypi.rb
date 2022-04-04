# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Pypi class
    class Pypi < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { pypi: name[/python.*-(.*)/, 1] || name }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        require 'json'
        retries ||= 0
        JSON.parse(get("https://pypi.org/pypi/#{opts[:pypi]}/json"))['releases'].keys
      rescue StandardError
        retry if (retries += 1) < 4
      end
    end
  end
end
