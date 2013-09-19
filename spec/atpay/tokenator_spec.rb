require 'atpay_tokens'
require 'rbnacl'
require 'base64'
require 'helper'

describe AtPay::Tokenator do
  let(:headers) { {'HTTP_USER_AGENT' => 'agent', 'HTTP_ACCEPT_LANGUAGE' => 'lang', 'HTTP_ACCEPT_CHARSET' => 'charset'} }
  let(:ip) { '1.1.1.1' }

  let(:payment) { AtPay::Tokenator.new token(50.00, [:email_token], {email: 'email@address'}), build_session }
  let(:site) { AtPay::Tokenator.new token(50.00, [:site_token, ip, headers], {card: 'OGQ3OWE0OWNhMFFTL4mMpQA='}), build_session }
  let(:user_data) { AtPay::Tokenator.new token(50.00, [:email_token], {email: 'email@address', user_data: 'lots of pills, paying forever'}), build_session }
  let(:version) { AtPay::Tokenator.new token(50.00, [:email_token], {email: 'email@address', version: 2}), build_session }
  let(:member) { AtPay::Tokenator.new token(50.00, [:email_token], {member: '4DF08A79-C16C-4842-AA1B-AE878C9C6C2C'}), build_session }
  let(:group) { AtPay::Tokenator.new token(50.00, [:email_token], {member: '4DF08A79-C16C-4842-AA1B-AE878C9C6C2C', group: '18', user_data: 'hello from data'}), build_session }
  let(:url) { AtPay::Tokenator.new token(50.00, [:email_token], {url: 'http://fake.url' }), build_session }

  describe "Parsing" do
    it "Uses the key specified in ENCRYPTION if not given a session" do
      tokenator = AtPay::Tokenator.new token(50.0, [:email_token], {email: 'email@address'})

      expect { tokenator.send(:boxer, Base64.decode64(public_key)) }.to raise_error
    end

    describe "Payment Tokens" do
      it "Extracts the partner" do
        payment.header

        payment.instance_eval { @partner_id }.should eq(123)
      end

      it "Extracts the body" do
        payment.header
        payment.body(Base64.decode64(public_key))

        payment.source[:email].should eq('email@address')
        payment.amount.should eq(50.0)
        payment.expires.should_not eq(nil)
      end

      it "Presents token values as a hash" do
        payment.header
        payment.body(Base64.decode64(public_key))

        payment.to_h.should be_a(Hash)
      end

      it "Processes a member token" do
        member.header
        member.body(Base64.decode64(public_key))

        member.source[:member].should eq('4DF08A79-C16C-4842-AA1B-AE878C9C6C2C')
      end

      it "Processes a token with a group" do
        group.header
        group.body(Base64.decode64(public_key))

        group.group.should eq('18')
        group.user_data.should eq('hello from data')
      end

      it "processes a url token" do
        url.header
        url.body Base64.decode64(public_key)

        url.source[:url].should eq('http://fake.url')
      end
    end

    describe "Exceptions" do
      it "Raises target not found if there is no valid target" do
        expect { payment.send :target, 'mom' }.to raise_error
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

      it "Extracts payload after extracting site frame" do
        site.header
        site.browser_data(Base64.decode64(public_key))
        site.body(Base64.decode64(public_key))

        site.source[:card].should eq('OGQ3OWE0OWNhMFFTL4mMpQA=')
        site.amount.should eq(50.0)
        site.expires.should_not eq(nil)
      end
    end

    describe "User Data" do
      it "Extracts supplied User Data" do
        user_data.header
        user_data.body(Base64.decode64(public_key))

        user_data.user_data.should eq('lots of pills, paying forever')
      end
    end

    describe "Versioning" do
      let(:versioned) { token(50.00, [:email_token], {email: 'email@address', version: 2}) }

      it "Extracts the version" do
        AtPay::Tokenator.token_version(versioned).should eq(2)
      end

      it "Returns 0 when there is no version" do
        test_token = token(50.00, [:email_token], {email: 'email@address'})

        AtPay::Tokenator.token_version(test_token).should eq(0)
      end

      it "Behaves as a normal token when versioned" do
        version.header
        version.body(Base64.decode64(public_key))

        version.amount.should eq(50.0)
      end
    end

    describe "Checksum lookup" do
      before do
        class AtPay::SecurityKey; end
        class AtPay::ValidationToken; end

        AtPay::SecurityKey.should_receive(:find_by_encoded_key)
        AtPay::ValidationToken.should_receive(:find_by_encoded_key)
      end

      it "should look for a token with a matching checksum" do
        token = token(50.0, [:email_token], {email: 'email@address'})

        AtPay::Tokenator.find_by_checksum(token)
      end
    end

    describe "Amounts" do
      let(:site) { AtPay::Tokenator.new token(33.33, [:site_token, ip, headers], {card: 'OGQ3OWE0OWNhMFFTL4mMpQA='}), build_session }

      it "should decode into an amount at 33.33" do
        site.header
        site.browser_data(Base64.decode64(public_key))
        site.body(Base64.decode64(public_key))

        site.amount.should eq(33.33)
      end
    end
  end
end
