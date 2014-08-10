module Github
    HEADERS = {
        "User-Agent"    => "Ruby.Github.Api",
        "Accept"        => "application/vnd.github.v3+json",
        "Content-Type"  => "application/json"
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
      raise_config_error "Missing 'client_id'" if data[:client_id].to_s ==''
      data[:client_id]
    end

    def secret
      raise_config_error "Missing 'client secret'" if data[:client_secret].to_s==''
      data[:client_secret]
    end

end
