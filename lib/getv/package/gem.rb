# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Gem class
    class Gem < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { gem: name[/ruby(gem)?-(.*)/, 2] || name }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        require 'json'
        JSON.parse(get("https://rubygems.org/api/v1/versions/#{opts[:gem]}.json")).map do |v|
          v['number']
        end
      end
    end
  end
end
