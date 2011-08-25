module Picky

  module Backends

    #
    #
    class Redis < Backend

      attr_reader :client

      def initialize options = {}
        @client = options[:client] || ::Redis.new(:db => (options[:db] || 15))
      end

      def create_inverted bundle
        Redis::ListHash.new "#{bundle.identifier}:inverted", client
      end
      def create_weights bundle
        Redis::FloatHash.new "#{bundle.identifier}:weights", client
      end
      def create_similarity bundle
        Redis::ListHash.new "#{bundle.identifier}:similarity", client
      end
      def create_configuration bundle
        Redis::StringHash.new "#{bundle.identifier}:configuration", client
      end

      # Returns the result ids for the allocation.
      #
      # Developers wanting to program fast intersection
      # routines, can do so analogue to this in their own
      # backend implementations.
      #
      # Note: We use the amount and offset hints to speed Redis up.
      #
      def ids combinations, amount, offset
        return [] if combinations.empty?

        identifiers = combinations.inject([]) do |identifiers, combination|
          identifiers << "#{combination.identifier}"
        end

        result_id = generate_intermediate_result_id

        # Intersect and store.
        #
        client.zinterstore result_id, identifiers

        # Get the stored result.
        #
        results = client.zrange result_id, offset, (offset + amount)

        # Delete the stored result as it was only for temporary purposes.
        #
        # Note: I could also not delete it, but that would not be clean at all.
        #
        client.del result_id

        results
      end

      # Generate a multiple host/process safe result id.
      #
      # Note: Generated when this class loads.
      #
      require 'socket'
      def self.extract_host
        @host ||= Socket.gethostname
      end
      def host
        self.class.extract_host
      end
      extract_host
      def pid
        @pid ||= Process.pid
      end
      # Use the host and pid (generated lazily in child processes) for the result.
      #
      def generate_intermediate_result_id
        :"#{host}:#{pid}:picky:result"
      end

    end

  end

end