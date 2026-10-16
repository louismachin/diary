class ConnectionContext
    attr_reader :client, :verb, :tail

    def initialize(client, verb, tail)
        @client = client
        @verb   = verb
        @tail   = tail
    end

    def halt
        throw :close_connection
    end

    def not_verb
        client.puts "ContextError: Verb \"#{verb}\" is not defined."
        halt
    end
end