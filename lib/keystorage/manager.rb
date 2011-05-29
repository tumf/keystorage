require 'yaml'
require 'openssl'

module Keystorage
  class << self
    def list(group=nil,file=nil)
      Manager.new(file).list(group)
    end
    
    def set(group,key,value,file=nil)
      Manager.new(file).set(group,key,value)
    end
    
    def get(group,name,file=nil)
      Manager.new(file).get(group,name)
    end

    def delete(group,name=nil,file=nil)
      Manager.new(file).delete(group,name)
    end

  end

  class Manager

    def initialize(file=nil)
      @file = DEFAULT_FILE
      @file = file if file
    end

    def list(group=nil)
      data = Hash.new
      if File::exist?(@file)
        File.open(@file,'r') do |f|
          data = YAML.load(f)
          return data.keys unless group
          return data[group].keys if data[group]
        end
      end
      Hash.new
    end

    def get(group,name)
      raise "missing group" unless group
      raise "missing name" unless name

      begin
        File.open(@file,'r') do |f|
          data=YAML.load(f)
          raise "missing keystorage" unless data
          raise "missing group "+group unless data.has_key?(group)
          raise "missing group "+group+" name "+name unless data[group].has_key?(name)

          return decode(data[group][name])
        end
      rescue =>e
      end
      false
    end

    def all
      return YAML.load_file(@file) if File.exist?(@file)
      Hash.new
    end

    def set(group,key,value)
      data=all
      data = Hash.new unless data
      data[group] = Hash.new unless data.has_key?(group)
      data[group][key] = encode(value)
      write(data)
    end

    def write(data)
      File.open(@file,'w',0600) do |f|
        YAML.dump(data,f)
      end
    end

    def delete(group,name = nil)
      data = all
      if name
        data[group].delete(name)
      else
        data.delete(group)
      end
      write(data)
    end

    def encode(str,salt="3Qw9EtWE")
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt.pkcs5_keyivgen(salt)
      ((enc.update(str) + enc.final).unpack("H*")).to_s
    end

    def decode(str,salt="3Qw9EtWE")
      dec = OpenSSL::Cipher::Cipher.new('aes256')
      dec.decrypt.pkcs5_keyivgen(salt)
      (dec.update(Array.new([str]).pack("H*")) + dec.final)
    end
  end


end
