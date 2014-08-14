module GmailApi

  class Collection
    include Enumerable
    
    def initialize(client, response, resource, &block)
      
      @client = client
      @collection = []
      @resource = resource
      @response = response
      @block = block
      
      fail "Calls cannot be emtpy" if calls.empty?
      fail "Block must be given"   unless block_given?

      @batch_results = @client.execute_batch(calls) do |result|
        @collection << yield(@client, result)
      end

    end

    def calls
      JSON(@response.body)[@resource].map do |resource|
        { api_method: GmailApi.api.users.__send__(@resource).get, parameters: { id: resource['id'], format: 'full', 'userId'=>'me' } }
      end
    end

    def each(&block)
      @collection.each do |obj|
        yield(obj)
      end
    end

    def next_page
      self.class.new(@client, @client.execute(@response.next_page), @resource) do |client, result|
        @block.call(client, result)
      end
    end

  end
  
end