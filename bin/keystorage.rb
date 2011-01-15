#!/usr/bin/env ruby
require 'pp'
require 'optparse'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'keystorage/cli'

Keystorage::CLI::run(ARGV)
