require 'keystorage/command/base'

module Keystorage
  module Command
    class Help < Base
      class << self
        def run(argv,options)
          cmd = argv.shift
          puts Command.const_get(cmd.capitalize).help
        end
      end
    end
  end
end
