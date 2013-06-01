require 'atpay'
require 'rbnacl'
require 'base64'
require 'helper'
require 'pry'

describe AtPay::Tokenator do
  let(:headers) { {'HTTP_USER_AGENT' => 'agent', 'HTTP_ACCEPT_LANGUAGE' => 'lang', 'HTTP_ACCEPT_CHARSET' => 'charset'} }
  let(:ip) { '1.1.1.1' }

  let(:payment) { AtPay::Tokenator.new token('email<email@address>', 50.00, [:email_token]), build_session }
  let(:site) { AtPay::Tokenator.new token('email<email@address>', 50.00, [:site_token, ip, headers], {card: 'OGQ3OWE0OWNhMFFTL4mMpQA='}), build_session }
  let(:validation) { AtPay::Tokenator.new build_session, token() }

  describe "Parsing" do
    describe "Payment Tokens" do
      it "Extracts the partner" do
        payment.header

        payment.instance_eval { @partner_id }.should eq(123)
      end

      it "Extracts the body" do
        payment.header
        payment.body(Base64.decode64(public_key))

        payment.source.should eq('email@address')
        payment.amount.should eq(50.0)
        payment.expires.should_not eq(nil)
      end

      it "Presents token values as a hash" do
        payment.header
        payment.body(Base64.decode64(public_key))

        payment.to_h.should be_a(Hash)
      end
    end

    describe "Site Tokens" do
      it "Extracts the Partner" do
        site.header

        site.instance_eval { @partner_id }.should eq(123)
      end

      it "Extracts the site frame" do
        site.header
        site.browser_data(Base64.decode64(public_key))
        sha = Digest::SHA1.hexdigest((headers.values + [ip]).join)

        site.instance_eval { @site_frame }.should eq(sha)
        site.instance_eval { @ip }.should eq(ip)
      end
    end
  end
end