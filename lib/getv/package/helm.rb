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
        YAML.safe_load(get("#{opts[:url]}/index.yaml")).fetch('entries', {}).fetch(opts[:chart], []).map do |e|
          e['version']
        end
      end
    end
  end
end
