# Contributing

TrepScore will accept service integrations for services on our [integration list][integration-list] and we'll pay you to make them! You can see all the details of our [bounty program][bounty-program] on its [wiki page][bounty-program].

In order to maintain quality and ensure we can track your contributions, every service requires the following:
  
  - Set the service category using the DSL
  - Setting the maintainer using at least your github username or email address.
  - Thorough documentation about what the services does and what the options do.
  - Tests added to the test suite where appropriate

Any new services that don't meet the above criteria will be rejected; we have continuous integration setup that makes sure the bare minimums are met.

We'd also like the following information to help make a great experience for our users:

 - A URL for the service
 - A URL to a logo for the service (png or gif preferred)

You can annotate all of this directly in the service class itself, like so:

```ruby
class Service::SomeService < Service
  category :accounting

  string  :client_key
  pasword :client_secret
  
  url       'http://www.example.com'
  url_logo  'http://www.example.com/logo.png'

  maintained_by github: 'ryanfaerman',
                email:  'ryan@trepscore.com',
                web:    'www.trepscore.com/contact'

  def call
    #...
  end
end
```

Some services use OAuth to authenticate with their API; this too can be annotated in the service class itself:

```ruby
class Service::SomeOauthService < Service
  category :accounting

  url       'http://www.example.com'
  url_logo  'http://www.example.com/logo.png'

  maintained_by github: 'ryanfaerman',
                email:  'ryan@trepscore.com',
                web:    'www.trepscore.com/contact'

  oauth(provider: :omniauth_provider) do |response, extra|
    {
      realm_id: extra['realmId'],
      token: response['credentials']['token'],
      secret: response['credentials']['secret']
    }
  end

  def call
    #...
  end
end
```

The `oauth` accepts a provider symbol which is the same that OmniAuth would use (we use OmniAuth for all of our OAuth needs). The block acts as a filter, so we don't need to store the entire OAuth response for every user. It receives the response (directly from OmniAuth) and a hash called `extra` of the GET parameters.

The Maintainers are annotated by the following methods:

 - `:github` - a Github login.
 - `:web` - A URL to a contact form.
 - `:email` - An email address.

If you'd like to receive the bounty, you must provide a github login or email address. Your email address will take precedence over the github account when we payout the bounty.



## How to test your service

You can test your service in a ruby console:

0. Install the gems with `bundle install`
1. Start a console: `rake console`
2. Call your Service:

    ```ruby
    Service::MyService.call(data: {client_key: '...', client_secret: '...'})
    ```
3. Verify the data looks as you expect.


[bounty-program]: https://github.com/25-ventures/trepscore-services/wiki
[integration-list]: https://github.com/25-ventures/trepscore-services/wiki/Integrations
