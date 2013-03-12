# @Pay API Client

Client interface for the @Pay API and key generation for 
performance optimization. This library is designed for advanced
implementation of the @Pay API, with the primary purpose
of enhancing performance for high-traffic, heavily utilized
platforms. 

Interfaces here are implemented after receiving OAuth 2.0
privileges for the partner/user record. You cannot authenticate
directly to the API with this library at this moment.

## Installation

Add the 'atpay-client' gem to your Gemfile:

```ruby
#Gemfile

gem 'atpay', :github => "EasyGive/atpay-client"
```

## Configuration

With the `keys` scope, authenticate with OAuth, and make a request
to the 'keys' endpoint (see the api documentation at
https://sandbox-api.atpay.com/doc) to receive the partner_id,
public key and private key.

Apply these values to your configuration

```ruby
session = AtPay::Session.new({
  :environment  => :sandbox,    # Either :sandbox or :production
  :partner_id   => 1234,        # Integer value partner id
  :public_key   => "XXX",       # Provided public key
  :private_key  => "YYY"        # Provided private key
})
```

## Usage

In order for an @Pay user to make a purchase via email, they'll
need to send a specially crafted key to @Pay's address. You can
either use the OAuth API endpoints to generate buttons and keys,
or you can generate the keys yourself. In a high traffic 
environment you'll want to generate keys locally. 

Let's assume you have a member with an @Pay account, and you 
would like to include a $20.00 purchase in an email to them:

```ruby
@key = session.security_key(:amount => 20.00, :email => "test@example.com")
```

Now, include the `@key` in a mailto link within the email
addressed to transaction@payments.atpay.com. Your user will
make the purchase by clicking the mailto and sending the 
email. 

## Expiration

Keys will expire by default after two weeks. To extend or 
shorten the expiration time of your offer, just use the 
expires option and provide a unix timestamp representing the
desired expiration:

```ruby
@key = session.security_key({
  :amount   => 20.00,
  :email    => "test@example.com",
  :expires  => (Time.now.to_i + (3600 * 5)) # Expire in 5 hours
})
```

## Key Groups

You can generate groups of key values for a user that will automatically
invalidate all members of the group when one key is processed. This
is useful when sending out multiple keys via email when only one key should ever
be processed:

```ruby
@keys = session.security_key({
  :amount     => [20.00, 30.00, 40.00],
  :email      => "test@example.com"
})

# returns array length == 3
```
