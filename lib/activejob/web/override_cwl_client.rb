module CloudWatchLogger
  module Client
    module InstanceMethods
      def massage_message(incoming_message, _severity, _processid)
        outgoing_message = ''
        outgoing_message << case incoming_message
                            when Hash
                              masher(incoming_message)
                            when String
                              incoming_message
                            else
                              incoming_message.inspect
                            end
        outgoing_message
      end
    end
  end
end
