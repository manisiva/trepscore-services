module Github
  HEADERS = {
    "User-Agent"    => "Ruby.Github.Api",
    "Accept"        => "application/vnd.github.v3+json",
    "Content-Type"  => "application/json"
  }

  autoload :Base, 'github/base'
  autoload :Client, 'github/client'
  autoload :ClosedIssues, 'github/closed_issues'
  autoload :Commits, 'github/commits'
  autoload :Files, 'github/files'
  autoload :OpenIssues, 'github/open_issues'  
end

class Service::Github < Service
  string :token, :secret, :name, :repo
  category :developer_tools

  def call
    client = ::Github::Client.new(client_id: token, client_secret: secret, user_name: name, user_repo: repo)
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

  def name
    raise_config_error "Missing 'user_name'" if data[:user_name].to_s ==''
    data[:user_name]
  end

  def repo
    raise_config_error "Missing 'user_repo'" if data[:user_repo].to_s ==''
    data[:user_repo]
  end
end
