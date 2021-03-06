require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

require 'atpay_tokens'
require 'rspec/core/shared_context'

module Setup
  extend RSpec::Core::SharedContext

  let(:partner_id)      { 123 }
  let(:keys)            { 
    sec = RbNaCl::PrivateKey.generate
    pub = sec.public_key
    [pub.to_bytes, sec.to_bytes]
  }
  let(:public_key)      { Base64.strict_encode64(keys[0]) }
  let(:private_key)     { Base64.strict_encode64(keys[1]) }

  def token(amount, type, options = {})
    build_session.security_key({
      amount: amount,
    }.merge(options)).send(*type).to_s
  end

  def build_session
    AtPay::Session.new({
      public_key: public_key,
      private_key: private_key,
      partner_id: partner_id,
      environment: :test
    })
  end
end

RSpec.configure do |r|
  r.include Setup
end
