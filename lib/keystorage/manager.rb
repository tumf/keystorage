# coding: utf-8
require 'keystorage'
module Keystorage
  # ks = keystorage::Manager.new(:file =>"",:secret=> "P@ssword")
  # ks.get("mygroup","mykey") # => "mysecret"
  class Manager
    include Keystorage
    attr_reader :options
    def initialize options = {}
      @options = options
    end

    def groups
      file.keys.delete_if {|i| i == "@" }
    end

    def keys(group)
      file[group].keys
    end

    def get(group,key)
      raise SecretMissMatch unless valid?
      decode(file[group][key])
    end

    def set(group,key,value)
      raise RejectGroupName.new("Cannot use '@' for group name.") if group == "@"
      raise SecretMissMatch unless valid?

      data = file
      data[group] = {} unless data.has_key?(group)
      data[group][key] = {} unless data[group].has_key?(key)
      data[group][key] = encode(value)
      write(data)

      data[group][key]
    rescue Errno::ENOENT
      write({})
      retry
    end

    def password new_secret
      raise SecretMissMatch unless valid?

      # update passwords
      data = file.each { |name,keys|
        next if name == "@"
        keys.each { |key,value|
          keys[key] = encode(decode(value),new_secret)
        }
      }
      # update root group and write to file
      write root!(new_secret,data)
    rescue Errno::ENOENT
      write({})
      retry
    end

  end
end
