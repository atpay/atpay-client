# @Pay API Client

[![Build Status](https://travis-ci.org/atpay/atpay-client.png)](https://travis-ci.org/atpay/atpay-client) [![Coverage Status](https://coveralls.io/repos/atpay/atpay-client/badge.png?branch=master)](https://coveralls.io/repos/atpay/atpay-client/badge.png?branch=master)


Client interface for the @Pay API and key generation for 
performance optimization. This library is designed for advanced
implementation of the @Pay API, with the primary purpose
of enhancing performance for high-traffic, heavily utilized
platforms. 

Interfaces here are implemented after receiving OAuth 2.0
privileges for the partner/user record. You cannot authenticate
directly to the API with this library at this moment.

## Requirements

ruby >= 1.9

## Installation

Add the 'atpay_tokens' gem to your Gemfile:

```ruby
#Gemfile

gem 'atpay_tokens', :github => "atpay/atpay-client"
```

## Configuration

With the `keys` scope, authenticate with OAuth, and make a request
to the 'keys' endpoint (see the api documentation at
https://developer.atpay.com) to receive the partner_id,
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

## Command Line Usage

    $ atpay_tokens --help


### Parameters

    atpay_tokens v2.1
    Options:
             --private-key, -p <s>:   [global] The private key given to you by @Pay
              --public-key, -u <s>:   [global] @Pay's public key, given to you by @Pay
              --partner-id, -a <i>:   [global] The partner ID given to you by @Pay
             --environment, -e <s>:   [global] The environment you want to generate buttons for. Currently sandbox or production (default: production)
                  --config, -c <s>:   [global] The path to a configuration file in yml format
                    --type, -t <s>:   [global] The type of token to generate (site,email,universal)
                    --card, -r <s>:   [site-token, email-token] The card token associated with the recipient of this token. If `type` is site, this must be present
                   --email, -m <s>:   [email-token] The email associated with the receipt of this token. Incompatible when `type` is 'site'
                     --url, -l <s>:   [universal-token] The Signup url the recipient should go to if they don't have payment informaiton.  Incompatible when `type` is 'site' or 'email'
                  --amount, -o <f>:   [token] The amount a user should be charged for the transaction you're generating a token for (default: 5.0)
               --user-data, -s <s>:   [token] Data to pass back as a reference
                 --expires, -x <i>:   [token] Expiration date for token, integer value of seconds since epoch
       --header-user-agent, -h <s>:   [site-token] The HTTP_USER_AGENT from the client's request header (if `type` is 'site')
      --header-accept-language, -d <s>:   [site-token] The HTTP_ACCEPT_LANGUAGE from the client's request header (if `type` is 'site')
       --header-accept-charset <s>:   [site-token] The HTTP_ACCEPT_CHARSET from the client's request header (if `type` is 'site')
              --ip-address, -i <s>:   [site-token] The IP address of the token recipient (if `type` is 'site')
                     --version, -v:   Print version and exit
                            --help:   Show this message

* Parameters marked as [global] must be passed on the command line
* Parameters marked with [site-token] are required for site tokens
* Parameters marked with [email-token] are required for email tokens
* Parameters marked with [token] are accepted for both site and email tokens

### CSV via STDIN

All token arguments (arguments not marked as [global]) may be passed
to the command line utility via STDIN in CSV format. The first line of
the incoming CSV must be the headers for each column, using the full
option names above. For instance, to pass a CSV with amount, card tokens,
user_data, and email address:

```
  $ atpay_tokens --private-key="XYZ" --partner-id=999 --type=email < data.csv
```

```
  amount,user-data,card,email
  50.00,refid1,XbsfrYUjAHh0lWSoWS0q3ahIpxohpcM=,james@example.com
  100.00,refid2,XbsfrYUjAHh0lWSoWS0q3ahIpxohpcM=,james@example.com
  200.00,refid3,XbsfrYUjAHh0lWSoWS0q3ahIpxohpcM=,james@example.com
```

The above will print 3 tokens for amounts between 50 and 200 dollars,
all to charge the same credit card at the same email address. 

If you need to change the keys, partner id, or type, you'll need to
start a new instance of the utility for each change.

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

## User Data

You can pass in arbitrary data that will be returned to you upon the successful parsing of a token in @Pay's system.  There is a limit of 2500 characters on this argument.  It is expected to be a string beyond that any formatting should be returned as it was received.

```ruby
@key = session.security_key({
  :amount    => 20.00,
  :email     => 'email@address',
  :user_data => "{ sku: '82', cid: '3', notes: 'expedited' } "
})
```
