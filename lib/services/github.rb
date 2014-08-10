module Github
    HEADERS = {
        "User-Agent"    => "Ruby.Github.Api",
        "Accept"        => "application/vnd.github.v3+json",
        "Content-Type"  => "application/x-www-form-urlencoded"
    }

    autoload :Base, 'github/base'
    autoload :Client, 'github/client'
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
