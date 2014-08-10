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
    string :token, :secret
    category :developer_tools

    def call
      client = ::Github::Client.new(client_id: token, client_secret: secret)
      client.metrics
    end

    def token
      raise_config_error "Missing 'client_id'" if data['token'].to_s ==''
      data['token']
    end

    def secret
      raise_config_error "Missing 'client secret'" if data['secret'].to_s==''
      data['secret']
    end

end
