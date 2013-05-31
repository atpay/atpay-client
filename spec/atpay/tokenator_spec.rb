require 'atpay'
require 'rbnacl'
require 'base64'
require 'helper'
require 'pry'

describe AtPay::Tokenator do
  let(:subject) { AtPay::Tokenator.new token('email<email@address>', 50.00, :email_token), build_session }

  describe "Parsing" do
    it "Accepts a valid token" do
      subject
    end

    it "Extracts the partner" do
      subject.header

      subject.instance_eval { @partner_id }.should eq(123)
    end

    it "Extracts the body" do
      subject.header
      subject.body(Base64.decode64(public_key))

      subject.source.should eq('email@address')
      subject.amount.should eq(50.0)
      subject.expires.should_not eq(nil)
    end

    it "Presents token values as a hash" do
      subject.header
      subject.body(Base64.decode64(public_key))

      subject.to_h.should be_a(Hash)
    end
  end
end