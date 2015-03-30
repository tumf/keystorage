# coding: utf-8
require 'keystorage'
require 'keystorage/manager'
require 'thor'
require 'optparse'

module Keystorage
  class CLI < Thor
    include Keystorage

    class <<self
      def start(given_args = ARGV, config = {})
        # parse global options: Thor is not support global-options.
        # Like: command global-options subcommand options
        global_options = []
        OptionParser.new do |opt|
          @global_options.each { |name,config|
            case config[:type]
            when :boolean then
              opt.on(config[:aliases],"--#{name.to_s}") { |v| global_options << "--#{name.to_s}"}
              opt.on(config[:aliases],"--no-#{name.to_s}") { |v| global_options << "--no-#{name.to_s}"}
            when :string then
              opt.on(config[:aliases],"--#{name.to_s}=VALUE") { |v| global_options << "--#{name.to_s}=#{v}"}
            end
          }
          opt.parse!(given_args)
        end
        given_args+=global_options
        super(given_args,config)
      end

      def global_option *params
        @global_options ||= {}
        @global_options[params[0]] = params[1]
        class_option params[0],params[1]
      end
    end

    global_option :verbose, :aliases =>"-v", :type => :boolean
    global_option :debug, :aliases =>"-d", :type => :boolean
    global_option :file, :aliases =>"-f", :type => :string
    global_option :secret, :aliases =>"-s",:type => :string

    desc "groups", "List groups"
    def groups
      puts render(Manager.new(options).groups)
    end

    desc "keys", "List keys of the group"
    def keys(group)
      puts render(Manager.new(options).keys(group))
    end

    desc "get", "Get a encrypted value of the key of the group"
    def get(group,key)
      puts render(Manager.new(options).get(group,key))
    end

    desc "set", "Set a value of the key of the group"
    def set(group,key,value=nil)
      #@todo: ask if value == nil
      puts render Manager.new(options).set(group,key,value)
    end

    desc "password","Update storage secret"
    def password new_secret=nil
      #@todo: ask if new_secret == nil
      Manager.new(options).password(new_secret)
    end

  end
end
