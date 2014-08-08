module Github
    HEADERS = {
        "User-Agent"    => "Ruby.Github.Api",
        "Accept"        => "application/json",
        "Content-Type"  => "application/x-www-form-urlencoded"
    }

    autoload :Base, 'github/base'
end

class Service::Github < Service
    string :token
    category :developer_tools

    def call
      client = ::Github::Client.new(api_token: token)
      client.metrics
    end

    def token
      raise_config_error "Missing 'api_token'" if data['token'].to_s ==''
      data['token']
    end

end
