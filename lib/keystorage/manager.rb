require 'yaml'
require 'openssl'

class Manager

  def initialize(file)
    @file = file
  end

  def list(group=null)
    data = Hash.new
    if File::exist?(@file)
      File.open(@file,'r') do |f|
        data = YAML.load(f)
        return data.keys unless group
        return data[group].keys
      end
    end
    Hash.new
  end

  def get(group,name)
    raise "missing group" unless group
    raise "missing name" unless name

    File.open(@file,'r') do |f|
      data=YAML.load(f)
      raise "missing key" unless data[group][name]
      return decode(data[group][name])
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

    File.open(@file,'w',0600) do |f|
      YAML.dump(data,f)
    end
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


