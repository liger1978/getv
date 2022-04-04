# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Helm class
    class Helm < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { chart: name, url: nil, user: nil, password: nil }.merge(opts)
        super name, opts
      end

      private

      def retrieve_versions
        require 'yaml'
        retries ||= 0
        YAML.safe_load(get("#{opts[:url]}/index.yaml")).fetch('entries', {}).fetch(opts[:chart], []).map do |e|
          e['version']
        end
      rescue StandardError
        retry if (retries += 1) < 4
      end
    end
  end
end
