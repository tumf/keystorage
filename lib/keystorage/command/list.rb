require 'keystorage/command/base'
require 'keystorage/manager'

module Keystorage
  module Command
    class List < Base
      def execute(argv)
        site = argv.shift
        ks = Manager.new(@file)
        ks.list(site).each do |v|
          puts v
        end
      end

      class << self
        def help
          "Description:
    list in storage

Usage:
    keystrage [options] list [group]
"
        end
      end

    end
  end
end
