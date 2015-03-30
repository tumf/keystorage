#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'digest/md5'
require 'openssl'
require 'yaml'
require 'securerandom'

module Keystorage
  DEFAULT_SECRET="3Qw9EtWE"
  DEFAULT_FILE = File.join(ENV["HOME"],".keystorage")

  class NoRootGroup < StandardError; end
  class RejectGroupName < StandardError; end
  class SecretMissMatch < StandardError; end
  class NoSecret < StandardError; end
  class FormatNotSupport < StandardError; end

  def sign message,secret=secret
    raise NoSecret.new("set env KEYSTORAGE_SECRET") unless secret
    OpenSSL::HMAC.hexdigest('sha512',secret, message)
  end

  def token
    SecureRandom.urlsafe_base64(nil, false)
  end

  def root
    raise NoRootGroup unless file.has_key?("@")
    file["@"] || {}
  end

  def root! secret=secret,data=file
    data["@"] = {}
    data["@"]["token"] = token
    data["@"]["sig"] = sign(data["@"]["token"],secret)
    data
  end

  # file validation
  def valid?
    sign(root["token"]) == root["sig"]
  rescue NoRootGroup
    write root!
  end

  def encode(str,secret=secret)
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt.pkcs5_keyivgen(secret)
    ((enc.update(str) + enc.final).unpack("H*")).first.to_s
  end

  def decode(str,secret=secret)
    dec = OpenSSL::Cipher::Cipher.new('aes256')
    dec.decrypt.pkcs5_keyivgen(secret)
    (dec.update(Array.new([str]).pack("H*")) + dec.final)
  end

  def path
    options[:file] || ENV['KEYSTORAGE_FILE'] || DEFAULT_FILE
  end

  def file
    YAML.load(File.new(path)) || {}
  end

  def write data
    File.open(path,'w',0600) { |f| YAML.dump(data,f) }
  end

  def secret
    options[:secret] || ENV['KEYSTORAGE_SECRET'] || DEFAULT_SECRET
  end

  def render out,format =:text
    case format
    when :text then
      render_text out
    else
      raise FormatNotSupport.new(format.to_s)
    end
  end

  def render_text out
    if out.kind_of?(Array)
      out.join("\n")
    else
      out.to_s
    end
  end

end
