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
