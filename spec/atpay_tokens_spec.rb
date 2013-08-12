require 'helper'
require 'atpay_tokens'

describe "atpay_tokens" do
  let(:key_pattern) { /@((([A-Za-z0-9+=*]{4})*-)?([A-Za-z0-9+=\/]{4}){5,})/ }
  let(:base_args) { "--environment test --private-key \"#{private_key}\" --public-key \"#{public_key}\" --partner-id 1 --amount 24.0"}
  let(:universal_token_args) { "#{base_args} --type universal --url http://bob.com" }
  let(:site_token_args) { "#{base_args} --type site --card cardtoken --header-user-agent bob --header-accept-language en --header-accept-charset us --ip-address 127.0.0.1" }
  let(:email_token_args) { "#{base_args} --type email --email bob@bob.com" }
  let(:command) { File.dirname(__FILE__) + '/../bin/atpay_tokens' }

  describe "Universal Tokens" do
    it "returns an @Pay Token" do
      expect(`#{command} #{universal_token_args}`).to match(key_pattern)
    end

    it "returns a universal token" do
      tokenator = AtPay::Tokenator.new(`#{command} #{universal_token_args}`, build_session)

      tokenator.header
      tokenator.body Base64.decode64(public_key)

      expect(tokenator.source[:url]).to eq('http://bob.com')
    end
  end

  describe "Site Tokens" do
    it "returns an @Pay Token" do
      expect(`#{command} #{site_token_args}`).to match(key_pattern)
    end

    it "returns a site token" do
      tokenator = AtPay::Tokenator.new(`#{command} #{site_token_args}`, build_session)

      tokenator.header
      tokenator.browser_data Base64.decode64(public_key)
      tokenator.body Base64.decode64(public_key)

      expect(tokenator.source[:card]).to eq('cardtoken')
    end
  end

  describe "Email Tokens" do
    it "returns an @Pay Token" do
      expect(`#{command} #{email_token_args}`).to match(key_pattern)
    end

    it "returns an email token" do
      tokenator = AtPay::Tokenator.new(`#{command} #{email_token_args}`, build_session)

      tokenator.header
      tokenator.body Base64.decode64(public_key)

      expect(tokenator.source[:email]).to eq('bob@bob.com')
    end
  end
end