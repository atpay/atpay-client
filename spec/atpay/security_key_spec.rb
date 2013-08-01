# TODO: Decode utilities for further testing

require 'atpay_tokens'
require 'rbnacl'
require 'base64'
require 'helper'

describe AtPay::SecurityKey do
  let(:session){
    AtPay::Session.new({
      :partner_id     => partner_id,
      :private_key    => private_key,
      :public_key     => public_key,
      :environment    => :sandbox
    })
  }

  describe "#initialize" do
    it "fails when no email given" do
      expect {
        AtPay::SecurityKey.new(session, {
          :amount => 25,
          :email => nil
        })
      }.to raise_error
    end

    it "fails when no amount given" do
      expect {
        AtPay::SecurityKey.new(session, {
          :amount => nil,
          :email => "test@example.com"
        })
      }.to raise_error
    end

    it "fails when amount not float" do
      expect {
        AtPay::SecurityKey.new(session, {
          :amount => "25", 
          :email => "test@example.com"
        })
      }.to raise_error
    end
  end

  describe "#to_s" do
    it "returns a valid key" do
      key = AtPay::SecurityKey.new(session, {:email => "james@atpay.com", :amount => 25.00}).to_s
    end

    it "returns a key with a group" do
      key = AtPay::SecurityKey.new(session, {:email => "james@atpay.com", :amount => 25.00, :group => "1234"}).to_s
    end

    it "returns a key with user_data" do
      key = AtPay::SecurityKey.new(session, {:email => "glen@atpay.com", :amount => 25.00, :user_data => 'bacon and eggs'}).to_s
    end
  end
end
