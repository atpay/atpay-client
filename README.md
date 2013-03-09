# @Pay OAuth2.0 API Client

Client interface for the @Pay API and key generation for 
performance optimization. This library is designed for advanced
implementation of the @Pay API, with the primary purpose
of enhancing performance for high-traffic, heavily utilized
platforms. 

## Installation

Add the 'atpay-client' gem to your Gemfile:

```ruby
#Gemfile

gem 'atpay-client', :require => 'atpay'
```

## Configuration

Clients are provided with API keys for accessing OAuth 2.0
authentication endpoints, a partner ID value, and a keypair 
for encrypting and generating security keys (when applicable). 

Apply these values to your configuration

```ruby
AtPay::Base.config = {
  :environment  => :sandbox,    # Either :sandbox or :production
  :partner_id   => 1234,        # Integer value partner id
  :public_key   => "XXX",       # Provided public key
  :private_key  => "YYY"        # Provided private key
}
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
@key = AtPay::SecurityKey.new {
  :amount => 20.00, 
  :email => "test@example.com"
}.to_s
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
@key = AtPay::SecurityKey.new {
  :amount   => 20.00,
  :email    => "test@example.com",
  :expires  => (Time.now.to_i + (3600 * 5)) # Expire in 5 hours
}
```
