require 'faraday'
require 'faraday_middleware'

module Github
  class Base
    #Constants for this class comes here
    CLASS_NAME_WITH_ISSUE = "Issues"
    ISSUE_RESOURCE_PATH = "issues"
    OPEN_ISSUES = "open"
    CLOSED_ISSUES = "closed"
    
    include Enumerable

    def initialize(options = {})
      @options = options
      authenticate
    end

    def authenticate(token = @options[:client_id], secret = @options[:client_secret])
      default_params.merge! client_id: token, client_secret: secret
    end

    def get(options = {})
      return to_enum(__callee__, options) unless block_given?

      response = _get_resource(options)
      if response.success?
        data = [(response.body || [])].flatten
        data.each do |item|
          yield OpenStruct.new item
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
      (item.try(:type) || item.try(:status)).try(:to_sym)  if item.status != nil
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
      protocol + 'api.github.com/repos/' + slug 
    end

    def slug
      "#{owner}/#{name}"
    end
 
    def owner
      @options[:user_name]
    end

    def name
      @options[:user_repo]
    end

    def resource_path
      #The resource path should match the camelCased class name with the
      #first letter downcased.  
      klass = self.class.name.split('::').last
      klass[0] = klass[0].chr.downcase
      klass
    end

    def resource(klass_name)
      klass_name = klass_name.to_s.split('_').map(&:capitalize).join
      _klasses[klass_name] ||= begin
        klass = Object.const_get "::Github::#{klass_name}"
        klass.new @options
      end
    end

    def [](id)
      path = [resource_path, id.to_s].join '/'
      get(resource_path: path).first
    end

    def issue_resource_path
      ISSUE_RESOURCE_PATH
    end

    #dynamically passing state for the issues based on the class name
    def filter_conditions(resource_path)      	
      { :state => OPEN_ISSUES} if resource_path.start_with?(OPEN_ISSUES)
      { :state => CLOSED_ISSUES} if resource_path.start_with?(CLOSED_ISSUES)
    end    

    private
      def _get_resource(options = {})
        params = default_params.merge (options.delete(:params) ||  {})
        response = connection.get do |req|
          req.url (options.delete(:resource_path) || resource_path)
          req.url (issue_resource_path), filter_conditions(resource_path) if resource_path && resource_path.end_with?(CLASS_NAME_WITH_ISSUE)          
          req.headers = ::Github::HEADERS
          req.params 
        end
      end

      def _klasses
        @_klasses ||= {}
      end

      def default_params
        @default_params ||= {}
      end

      def connection
        @connection ||= ::Faraday.new(url: base_uri) do |conn|
          conn.request :url_encoded
          conn.adapter ::Faraday.default_adapter

          conn.response :json, content_type: /\bjson$/
          conn.response :xml,  content_type: /\bxml$/
        end
      end
  end
end
