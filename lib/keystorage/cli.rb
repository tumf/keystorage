require 'optparse'
require 'keystorage'
require 'keystorage/commands'

module Keystorage
  class CLI
    def initialize(argv)
      @options = Hash.new
      @options[:file] = DEFAULT_FILE
      @argv = argv.clone
      @opt = OptionParser.new
      @opt.banner="Usage: keystorage [options] command [command options] args..."
      @opt.on('--help', 'show this message') { usage; exit }
      @opt.on('-f FILE','--file=FILE', 'file to store password') { |v|
        @options[:file] = v;
      }
    end
    
    def usage
      puts @opt;
      puts "Commands:"
      @commands = ["list","set","get","help"]
      @commands.each do |m|
        puts "    "+m
      end
    end

    def execute
      argv = @opt.parse(@argv)
      command = argv.shift
      unless command
        usage;exit
      end
      Commands.send(command,argv,@options) 
    end

    class << self
      def run(argv)
        self.new(argv).execute
      end
    end
  end
end

