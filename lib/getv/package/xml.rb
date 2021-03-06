# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Xml class
    class Xml < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { url: nil, user: nil, password: nil, xpath: '//a/@href' }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        retries ||= 0
        require 'nokogiri'
        Nokogiri::XML(get(opts[:url])).xpath(opts[:xpath]).map(&:text)
      rescue StandardError
        retry if (retries += 1) < 4
      end
    end
  end
end
