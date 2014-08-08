require 'faraday'
require 'faraday_middleware'

module Github
    class Base

      include Enumerable

      def initialize(option = {})
        @options = options
        authenticate
      end

      def authenticate(token = @options[:api_token])
        default_params.merge! api_token: token
      end

      def get(options = {})
        return to_enum(__callee__, options) unless block_given?

        response = _get_resource(options)
        if response.success?
          data = [(response.body['data'] || [])].flatten
          data.each do |item|
            yield OpenStruct.new item
          end
          
          if next_start(response)
            options[:params] = (options[:params]||{}).merge({start:next_start(response)})
            send(__callee__, options) do |data|
              yield data
            end
         end
       end
      
    end
    alias_method :each, :get

    def metrics
      metrics = {total: all.count}

      get.each do |item|
        key = metric_key(item)
        break if key.nil?

        metrics[key] ||= 0
        metrics[key] += 1
      end

      metrics
    end

    def metric_key(item)
      (item.try(:type) || item.try(:status)).try(:to_sym)
    end

    def all(options = {})
      data = []
      each(options).collect {|i| data << i}
      data
    end

    def prepare_options(options = {})
      options
    end

    def protocol
      'https://'
    end
    
    def base_uri
      protocol + 'api.github.com'
    end

   private
     def _get_resource(options = {})
       params = default_params.merge (options.delete(:params) || {})

       response = connection.get do |req|
         req.headers = ::Github::HEADERS
         req.params.merge! params
       end
     end

     def connection
       @connection ||= ::Faraday.new(url: base_uri) do |conn|
         conn.request :url_encoded
         conn.adapter ::Faraday.default_adapter

         conn.response :json, content_type: /\bjson$/
         conn.response :xml, content_type: /\bxml$/
       end
     end
   end
 end















