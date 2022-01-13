module Getv
  class Package
    attr_accessor :name, :opts

    def initialize(name, opts={})
      @name = name
      if /rubygem-.*/.match?(name)
        opts = {'type' => 'gem'}.merge(opts)
      elsif /nodejs-.*/.match?(name)
        opts = {'type' => 'npm'}.merge(opts)
      elsif /python.*-.*/.match?(name)
        opts = {'type' => 'pypi'}.merge(opts)
      end
      opts = {
        :type => 'github_release',
        :select => {
          :search => '^\s*v?((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)\s*$',
          :replace => '\1'
        },
        :reject => nil,
        :semantic_only => true,
        :semantic_select => ['*'],
        :versions => nil,
        :latest_version => nil,
      }.merge(opts)
      case opts[:type]
      when 'docker'
        opts = {:owner => 'library', :repo => name, :url=> 'https://registry.hub.docker.com'}.merge(opts)
      when 'gem'
        opts = {:gem => name[/rubygem-(.*)/, 1] || name}.merge(opts)
      when /github.*/
        opts = {:owner => name, :repo => name,}.merge(opts)
      when 'index'
        opts = {:link => 'content'}.merge(opts)
      when 'npm'
        opts = {:npm => name[/nodejs-(.*)/, 1] || name}.merge(opts)
      when 'pypi'
        opts = {:npm => name[/python.*-(.*)/, 1] || name}.merge(opts)
      end
      @opts = opts
    end
    
    def get_latest_version
      if opts[:latest_version] == nil
        self.update_versions
      end
      opts[:latest_version]
    end

    def get_versions
      if opts[:version] == nil
        self.update_versions
      end
      opts[:versions]
    end

    def update_versions
      case opts[:type]
      when 'docker'
        versions = get_versions_using_docker
      when 'gem'
        versions = get_versions_using_gem
      when 'get'
        versions = get_versions_using_get
      when 'github_release'
        versions = get_versions_using_github('release')
      when 'github_tag'
        versions = get_versions_using_github('tag')
      when 'index'
        versions = get_versions_using_index
      when 'npm'
        versions = get_versions_using_npm
      when 'pypi'
        versions = get_versions_using_pypi
      end
      select_pattern = Regexp.new(opts[:select][:search])
      versions.select! {|v| v =~ select_pattern}
      versions.map! {|v| v.sub(select_pattern, opts[:select][:replace])}
      unless opts[:reject].nil?
        versions.reject! {|v| v =~ Regexp.new(opts[:reject])}
      end
      if opts[:semantic_only]
        require 'semantic'
        require 'semantic/core_ext'
        versions.select! {|v| v.is_version?}
        opts[:semantic_select].each do |comparator|
          versions.select! {|v| Semantic::Version.new(v).satisfies?(comparator)}
        end
        versions.sort_by! {|v| Semantic::Version.new(v)}
      else
        versions.sort!
      end
      opts[:versions] = versions
      unless opts[:versions].empty?
        opts[:latest_version] = opts[:versions][-1]
      end
    end

    private

    def get_versions_using_docker
      require 'docker_registry2'
      docker = DockerRegistry2.connect(opts[:url])
      return docker.tags("#{opts[:owner]}/#{opts[:repo]}")['tags'] 
    end

    def get_versions_using_gem
      require 'json'
      require 'open-uri'
      require 'net/http'
      return JSON.parse(Net::HTTP.get(URI("https://rubygems.org/api/v1/versions/#{opts[:gem]}.json"))).map {|v| v['number']}
    end

    def get_versions_using_get
      require 'open-uri'
      require 'net/http'
      return Net::HTTP.get(URI(opts[:url])).split("\n")
    end

    def get_versions_using_github(method)
      require 'octokit'
      if ENV['GITHUB_TOKEN']
        github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
        user = github.user
        user.login
      else
        github = Octokit::Client.new()
      end
      if method == 'release'
        return github.releases("#{opts[:owner]}/#{opts[:repo]}").map{|r| r.tag_name}
      else
        return github.tags("#{opts[:owner]}/#{opts[:repo]}").map{|t| t[:name]}
      end
    end

    def get_versions_using_index
      require 'open-uri'
      require 'net/http'
      require 'nokogiri'
      if opts[:link] == 'value'
        versions = Nokogiri::HTML(URI.open(opts[:url])).css('a').map{|a| a.values[0]}
      else
        versions = Nokogiri::HTML(URI.open(opts[:url])).css('a').map{|a| a.public_send(opts[:link])}
      end
      return versions
    end

    def get_versions_using_npm
      require 'json'
      require 'open-uri'
      require 'net/http'
      return JSON.parse(Net::HTTP.get(URI("https://registry.npmjs.org/#{opts[:npm]}")))['versions'].keys
    end

    def get_versions_using_pypi
      require 'json'
      require 'open-uri'
      require 'net/http'
      return JSON.parse(Net::HTTP.get(URI("https://pypi.org/pypi/#{opts[:pypi]}/json")))['releases'].keys
    end

  end
end
