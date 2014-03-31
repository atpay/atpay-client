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

    it "fails when not given an email or card or member or url" do
      expect {
        AtPay::SecurityKey.new(session, {
          amount: 25.00
        })
      }.to raise_error
    end
  end

  describe "#target" do
    it "builds a card string if card option given" do
      for_card = AtPay::SecurityKey.new(session, amount: 25.0, card: 'fakecardtoken')

      expect(for_card.send(:target)).to eq("card<fakecardtoken>")
    end

    it "builds an email string if email option given" do
      for_email = AtPay::SecurityKey.new(session, amount: 25.0, email: 'bob@bob')

      expect(for_email.send(:target)).to eq("email<bob@bob>")
    end

    it "builds a member string if member option given" do
      for_member = AtPay::SecurityKey.new(session, amount: 25.0, member: 'fakemember')

      expect(for_member.send(:target)).to eq("member<fakemember>")
    end

    it "builds a url string if url option given" do
      for_url = AtPay::SecurityKey.new(session, amount: 25.0, url: 'http://fake.url.com')

      expect(for_url.send(:target)).to eq("url<http://fake.url.com>")
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

    it "encapsulates the key with @" do
      key = AtPay::SecurityKey.new(session, {email: 'glen@atpay.com', amount: 25.00}).to_s

      expect(key[0]).to eq('@')
      expect(key[-1]).to eq('@')
    end
  end
end
