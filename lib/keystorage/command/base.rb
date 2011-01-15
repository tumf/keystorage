module Keystorage
  module Command
    class Base

      def initialize(options)
        @file = options[:file]
      end

      class << self
        def run(argv,options)
          begin
            self.new(options).execute(argv)
          rescue =>e
            puts "Error: \n    %s\n\n" % e
            puts help
          end
        end

        def help
          "TODO: HELP IS NOT DESCRIBED YET."
        end

      end
    end
  end
end
