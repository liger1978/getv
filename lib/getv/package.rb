# frozen_string_literal: true

module Getv
  # package class
  class Package # rubocop:disable Metrics/ClassLength
    attr_accessor :name, :opts

    def initialize(name, opts = {}) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
      @name = name
      case name
      when /rubygem-.*/
        opts = { type: 'gem' }.merge(opts)
      when /nodejs-.*/
        opts = { type: 'npm' }.merge(opts)
      when /python.*-.*/
        opts = { type: 'pypi' }.merge(opts)
      end
      if opts[:type] == 'github_commit'
        opts = {
          branch: 'master',
          select_search: '^((\d{8})(\d{6}),(([a-z\d]{7})(.*)))$',
          semantic_only: false
        }.merge(opts)
      end
      opts = {
        type: 'github_release',
        select_search: '^\s*v?(.*)\s*$',
        select_replace: '\1',
        reject: nil,
        semantic_only: true,
        semantic_select: ['*'],
        proxy: nil,
        versions: nil,
        latest_version: nil
      }.merge(opts)
      case opts[:type]
      when 'docker'
        opts = { user: nil, password: nil }.merge(opts)
        opts = case name.count('/')
               when 0
                 { owner: 'library', repo: name, url: 'https://registry.hub.docker.com' }.merge(opts)
               when 1
                 { owner: name.split('/')[0], repo: name.split('/')[1],
                   url: 'https://registry.hub.docker.com' }.merge(opts)
               else
                 { owner: name.split('/')[1], repo: name.split('/')[2..-1].join('/'),
                   url: "https://#{name.split('/')[0]}" }.merge(opts)
               end
      when 'gem'
        opts = { gem: name[/rubygem-(.*)/, 1] || name }.merge(opts)
      when /github.*/
        opts = { token: nil }.merge(opts)
        opts = case name.count('/')
               when 1
                 { owner: name.split('/')[0], repo: name.split('/')[1] }.merge(opts)
               else
                 { owner: name, repo: name }.merge(opts)
               end
      when 'helm'
        opts = { chart: name, url: nil, user: nil, password: nil }.merge(opts)
      when 'index'
        opts = { link: 'content' }.merge(opts)
      when 'npm'
        opts = { npm: name[/nodejs-(.*)/, 1] || name }.merge(opts)
      when 'pypi'
        opts = { pypi: name[/python.*-(.*)/, 1] || name }.merge(opts)
      end
      @opts = opts
    end

    def latest_version
      update_versions if opts[:latest_version].nil?
      opts[:latest_version]
    end

    def versions
      update_versions if opts[:versions].nil?
      opts[:versions]
    end

    def update_versions # rubocop:disable Metrics/PerceivedComplexity,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
      method = opts[:type].split('_')
      method[0] = "versions_using_#{method[0]}"

      versions = send(*method)
      versions.sort! if opts[:type] == 'github_commit'
      select_pattern = Regexp.new(opts[:select_search])
      versions.select! { |v| v =~ select_pattern }
      versions.map! { |v| v.sub(select_pattern, opts[:select_replace]) }
      versions.reject! { |v| v =~ Regexp.new(opts[:reject]) } unless opts[:reject].nil?
      if opts[:semantic_only]
        require 'semantic'
        require 'semantic/core_ext'
        versions.select!(&:is_version?)
        opts[:semantic_select].each do |comparator|
          versions.select! { |v| Semantic::Version.new(v).satisfies?(comparator) }
        end
        versions.sort_by! { |v| Semantic::Version.new(v) }
      else
        versions.sort! unless opts[:type] == 'github_commit'
      end
      opts[:versions] = versions.uniq
      opts[:latest_version] = opts[:versions][-1] unless opts[:versions].empty?
    end

    private

    def get(url) # rubocop:disable Metrics/AbcSize
      require 'rest-client'
      if opts[:user] && opts[:password]
        RestClient::Request.execute(method: :get, url: url, proxy: opts[:proxy], user: opts[:user],
                                    password: opts[:password]).body
      else
        RestClient::Request.execute(method: :get, url: url, proxy: opts[:proxy]).body
      end
    end

    def versions_using_docker # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      require 'docker_registry2'
      docker_opts = {}
      docker_opts[:http_options] = { proxy: opts[:proxy] } unless opts[:proxy].nil?
      if opts[:user] && opts[:password]
        docker_opts[:user] = opts[:user]
        docker_opts[:password] = opts[:password]
      end
      docker = DockerRegistry2.connect(opts[:url], docker_opts)
      docker.tags("#{opts[:owner]}/#{opts[:repo]}")['tags']
    rescue DockerRegistry2::NotFound
      []
    end

    def versions_using_gem
      require 'json'
      JSON.parse(get("https://rubygems.org/api/v1/versions/#{opts[:gem]}.json")).map do |v|
        v['number']
      end
    end

    def versions_using_get
      get(opts[:url]).split("\n")
    end

    def github # rubocop:disable Metrics/MethodLength
      require 'octokit'
      if opts[:token]
        github = Octokit::Client.new(access_token: opts[:token])
        user = github.user
        user.login
      else
        github = Octokit::Client.new
      end
      github.auto_paginate = true
      github.proxy = opts[:proxy]
      github
    end

    def versions_using_github(method) # rubocop:disable Metrics/AbcSize
      case method
      when 'release'
        github.releases("#{opts[:owner]}/#{opts[:repo]}").map(&:tag_name)
      when 'commit'
        github.commits("#{opts[:owner]}/#{opts[:repo]}", opts[:branch]).map do |c|
          "#{DateTime.parse(c[:commit][:author][:date].to_s).strftime('%Y%m%d%H%M%S')},#{c[:sha]}"
        end
      else
        github.tags("#{opts[:owner]}/#{opts[:repo]}").map { |t| t[:name] }
      end
    end

    def versions_using_helm
      require 'yaml'
      YAML.safe_load(get("#{opts[:url]}/index.yaml")).fetch('entries', {}).fetch(opts[:chart], []).map { |e| e['version'] }
    end

    def versions_using_index
      require 'nokogiri'
      Nokogiri::HTML(get(opts[:url])).css('a').map do |a|
        if opts[:link] == 'value'
          a.values[0]
        else
          a.public_send(opts[:link])
        end
      end
    end

    def versions_using_npm
      require 'json'
      JSON.parse(get("https://registry.npmjs.org/#{opts[:npm]}"))['versions'].keys
    end

    def versions_using_pypi
      require 'json'
      JSON.parse(get("https://pypi.org/pypi/#{opts[:pypi]}/json"))['releases'].keys
    end
  end
end
