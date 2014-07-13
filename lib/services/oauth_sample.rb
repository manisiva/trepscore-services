class Service::OauthSample < Service

  string :foobar
  boolean :facepunch

  oauth(provider: :google_oauth2) do |response, extra|
    {
      realm_id: extra[:realmId],
      token: response[:token][:token][:token]
    }
  end
end