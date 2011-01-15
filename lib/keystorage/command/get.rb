require 'keystorage/command/base'

module Keystorage
  module Command
    class Get < Base
      def execute(argv)
        group = argv.shift
        raise "missing parameter"  unless group
        
        name = argv.shift
        ks = Manager.new(@file)
        data = ks.get(group,name)
        raise "missing %s " % [group] unless data
        puts data
      end

      class << self
        def help
          "Description:
    get key from file

Usage:
    keystrage [options] get groups [name]
"
        end
      end
    end
  end
end
