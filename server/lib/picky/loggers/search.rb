# encoding: utf-8
#
module Picky

  # TODO Remove?
  #
  module Loggers # :nodoc:all

    # Log Proxy
    #
    class Search

      attr_reader :logger

      def initialize logger
        @logger = logger
      end

      def log message
        logger.info message
      end

    end
  end

end