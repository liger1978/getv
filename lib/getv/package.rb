# frozen_string_literal: true

module Getv
  # Getv::Package class
  class Package
    attr_accessor :name, :opts

    def self.create(name, opts = {})
      if opts.fetch(:type, nil).nil?
        opts.delete(:type)
        create_using_name(name, opts)
      else
        type = opts[:type]
        opts.delete(:type)
        type_to_class(type).new name, opts
      end
    end

    private_class_method def self.create_using_name(name, opts)
      case name
      when /ruby(gem)?-.*/
        Getv::Package::Gem.new name, opts
      when /node(js)?-.*/
        Getv::Package::Npm.new name, opts
      when /python.*-.*/
        Getv::Package::Pypi.new name, opts
      else
        Getv::Package::GitHub::Release.new name, opts
      end
    end

    private_class_method def self.type_to_class(type)
      sections = type.split(/_|::| |-|:/)
      sections.each(&:capitalize!)
      sections.each { |section| section.sub! 'Github', 'GitHub' }
      type = sections.join '::'
      Object.const_get("Getv::Package::#{type}")
    end

    def initialize(name, opts = {})
      @name = name
      @opts = opts
    end

    def defaults # rubocop:disable Metrics/MethodLength
      {
        select_search: '^\s*v?(.*)\s*$',
        select_replace: '\1',
        reject: nil,
        semantic_only: true,
        semantic_prefix: nil,
        semantic_select: ['*'],
        proxy: nil,
        versions: nil,
        latest_version: nil
      }
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
      versions = retrieve_versions || []
      versions.sort! if instance_of?(Getv::Package::GitHub::Commit)
      select_pattern = Regexp.new(opts[:select_search])
      versions.select! { |v| v =~ select_pattern }
      versions.map! { |v| v.sub(select_pattern, opts[:select_replace]) }
      versions.reject! { |v| v =~ Regexp.new(opts[:reject]) } unless opts[:reject].nil?

      if opts[:semantic_only]
        require 'semantic'
        require 'semantic/core_ext'

        # remove non semantic version tags
        versions.select! do |v|
          v.sub(/^#{opts[:semantic_prefix]}/, '').is_version? && v.start_with?(opts[:semantic_prefix].to_s)
        end

        opts[:semantic_select].each do |comparator|
          versions.select! do |v|
            Semantic::Version.new(v.sub(/^#{opts[:semantic_prefix]}/, '')).satisfies?(comparator)
          end
        end
        versions.sort_by! { |v| Semantic::Version.new(v.sub(/^#{opts[:semantic_prefix]}/, '')) }
      else
        versions.sort! unless instance_of?(Getv::Package::GitHub::Commit)
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
  end
end
