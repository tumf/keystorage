require 'keystorage/command/base'

module Keystorage
  module Command
    class Set < Base
      def execute(argv)
        group = argv.shift
        var = argv.shift
        val = argv.shift
        ks = Manager.new(@file)
        ks.set(group,var,val)
      end
      class << self
        def help
          "Description:
    store key to file

Usage:
    keystrage [options] set group name key
"
        end
      end
    end
  end
end
