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

    def exec *cmd
      raise SecretMissMatch unless valid?
      system(envs.collect{ |k,v| "#{k}='#{v}'" }.join(' ') + " " + cmd.join(' '))
    end

    private

    def envs
      result = {}
      groups.each { |g|
        keys(g).each { |k|
          result["#{g}_#{k}"] = get(g,k)
        }
      }
      result
    end

    def sign message,_secret=secret
      raise NoSecret.new("set env KEYSTORAGE_SECRET") unless _secret
      OpenSSL::HMAC.hexdigest('sha512',_secret, message)
    end

    def token
      SecureRandom.urlsafe_base64(nil, false)
    end

    def root
      raise NoRootGroup unless file.has_key?("@")
      file["@"] || {}
    end

    def root! _secret=secret,data=file
      data["@"] = {}
      data["@"]["token"] = token
      data["@"]["sig"] = sign(data["@"]["token"],_secret)
      data
    end

    # file validation
    def valid?
      sign(root["token"]) == root["sig"]
    rescue NoRootGroup
      write root! and true
    end

    def encode(str,_secret=secret)
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt.pkcs5_keyivgen(_secret)
      ((enc.update(str) + enc.final).unpack("H*")).first.to_s
    end

    def decode(str,_secret=secret)
      dec = OpenSSL::Cipher::Cipher.new('aes256')
      dec.decrypt.pkcs5_keyivgen(_secret)
      (dec.update(Array.new([str]).pack("H*")) + dec.final)
    end

    def path
      options[:file] || ENV['KEYSTORAGE_FILE'] || DEFAULT_FILE
    end

    def file
      YAML.load(File.new(path)) || {}
    end

    def write data
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path,'w',0600) { |f| YAML.dump(data,f) }
    end

    def secret
      options[:secret] || ENV['KEYSTORAGE_SECRET'] || DEFAULT_SECRET
    end

  end
end
