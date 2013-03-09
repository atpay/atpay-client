require 'atpay'
require 'nacl'
require 'base64'
require 'helper'

describe AtPay::SecurityKey do
  before do
    AtPay::Base.config = {
      :partner_id     => partner_id,
      :private_key    => private_key,
      :public_key     => public_key,
      :environment    => :sandbox
    }
  end

  describe "#initialize" do
    it "fails when no email given" do
      expect {
        AtPay::SecurityKey.new :amount => 25,
          :email => nil
      }.to raise_error
    end

    it "fails when no amount given" do
      expect {
        AtPay::SecurityKey.new :amount => nil,
          :email => "test@example.com"
      }.to raise_error
    end

    it "fails when amount not float" do
      expect {
        AtPay::SecurityKey.new :amount => "25", 
          :email => "test@example.com"
      }.to raise_error
    end
  end

  describe "#to_s" do
    it "returns a valid key" do
      key = AtPay::SecurityKey.new(:email => "james@atpay.com", :amount => 25.00).to_s
    end
  end

end
