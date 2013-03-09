require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler/setup'
require 'atpay'
require 'rspec/core/shared_context'

module Setup
  extend RSpec::Core::SharedContext

  let(:partner_id)      { 123 }
  let(:keys)            { NaCl.crypto_box_keypair }
  let(:public_key)      { Base64.encode64(keys[0]) }
  let(:private_key)     { Base64.encode64(keys[1]) }
end

RSpec.configure do |r|
  r.include Setup
end
