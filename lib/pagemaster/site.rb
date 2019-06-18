# frozen_string_literal: true

module Pagemaster
  class Site
    attr_reader :config, :args, :opts, :collections

    #
    #
    def initialize(config = nil, args, opts)
      @config           = config || config_from_file
      @args             = args
      @opts             = opts
      @collections      = collections
      @collections_dir  = @config.dig 'collections_dir'
      @source_dir       = @config.dig 'source_dir'

      raise Error::MissingArgs, 'You must specify one or more collections after `jekyll pagemaster`' if @args.empty?
      raise Error::InvalidCollection, "Cannot find collection(s) #{@args} in config" if @collections.empty?
    end

    #
    #
    def config_from_file
      YAML.load_file "#{`pwd`.strip}/_config.yml"
    end

    #
    #
    def collections
      collections_config = @config.dig 'collections'

      raise Error::InvalidConfig, "Cannot find collections settings in _config.yml" if collections_config.nil?

      args.map do |a|
        raise Error::InvalidArgument, "Cannot find requested collection #{a} in _config.yml" unless collections_config.key? a

        Collection.new(a, collections_config.fetch(a))
      end
    end

    #
    #
    def generate_pages
      @collections.each { |c| c.generate_pages(@opts, @collections_dir, @source_dir) }

      puts Rainbow("Done ✔").green
    end
  end
end
