require 'keystorage/command/help'
require 'keystorage/command/list'
require 'keystorage/command/set'
require 'keystorage/command/get'

module Keystorage
  class Commands
    class << self
      def help(argv,options)
        Command::Help.run(argv,options)
      end
      
      def list(argv,options)
        Command::List.run(argv,options)
      end
      
      def set(argv,options)
        Command::Set.run(argv,options)
      end
      
      def get(argv,options)
        Command::Get.run(argv,options)
      end
    end
  end
end
