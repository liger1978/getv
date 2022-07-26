# frozen_string_literal: true

module Getv
  class Package
    # Getv::Package::Docker class
    class Docker < Package
      def initialize(name, opts = {})
        opts = defaults.merge(opts)
        opts = { user: nil, password: nil, auto_paginate: true }.merge(opts)
        opts = docker_defaults(name).merge(opts)
        super name, opts
      end

      private

      def docker_defaults(name)
        case name.count('/')
        when 0
          { owner: 'library', repo: name, url: 'https://registry.hub.docker.com' }
        when 1
          { owner: name.split('/')[0], repo: name.split('/')[1],
            url: 'https://registry.hub.docker.com' }
        else
          { owner: name.split('/')[1], repo: name.split('/')[2..].join('/'),
            url: "https://#{name.split('/')[0]}" }
        end
      end

      def docker_opts
        d_opts = {}
        d_opts[:http_options] = { proxy: opts[:proxy] } unless opts[:proxy].nil?
        if opts[:user] && opts[:password]
          d_opts[:user] = opts[:user]
          d_opts[:password] = opts[:password]
        end
        d_opts
      end

      def retrieve_versions # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        require 'docker_registry2'
        retries ||= 0
        docker = DockerRegistry2.connect(opts[:url], docker_opts)
        docker.tags("#{opts[:owner]}/#{opts[:repo]}", auto_paginate: opts[:auto_paginate])['tags'] || []
      rescue DockerRegistry2::NotFound
        []
      rescue StandardError => e
        if (retries += 1) < 4
          retry
        else
          puts "Error fetching tags for docker image #{opts[:url]}/#{opts[:owner]}/#{opts[:repo]}:"
          puts e.message
        end
      end
    end
  end
end
