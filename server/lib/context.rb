class ConnectionContext
    attr_reader   :client
    attr_accessor :verb, :tail, :body, :action
    
    def initialize(client, body, action = 'ENTRY')
        @client = client
        @body   = body
        @action = action
    end

    def halt
        throw :close_connection
    end

    def not_verb
        client.puts "ContextError: Verb \"#{verb}\" is not defined."
        halt
    end
end