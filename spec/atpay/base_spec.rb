require 'helper'

describe AtPay::Base do
  describe "overview" do
    it "accepts multiple arguments" do
      AtPay::Base.should_receive(:partner_id=).with(partner_id)
      AtPay::Base.should_receive(:private_key=).with(private_key)
      AtPay::Base.should_receive(:public_key=).with(public_key)
      AtPay::Base.should_receive(:environment=).with(:sandbox)

      AtPay::Base.config = {
        :partner_id     => partner_id,
        :private_key    => private_key,
        :public_key     => public_key,
        :environment    => :sandbox
      }
    end
  end

  describe "values" do
    before do
      AtPay::Base.config = {
        :partner_id     => partner_id,
        :private_key    => private_key,
        :public_key     => public_key,
        :environment    => :sandbox
      }
    end

    it "accepts partner id" do
      AtPay::Base.partner_id = partner_id
      AtPay::Base.partner_id.should eq(partner_id)
    end

    it "accepts private key" do
      AtPay::Base.private_key = private_key
      AtPay::Base.private_key.should_not be_empty
    end

    it "accepts public key" do
      AtPay::Base.public_key = public_key
      AtPay::Base.public_key.should_not be_empty
    end

    it "accepts environment" do
      AtPay::Base.environment = :sandbox
      AtPay::Base.atpay_public_key.should_not be_empty
    end
  end

  describe "environment" do
    it "required to be production or sandbox" do
      expect {
        AtPay::Base.config = { :environment => :none }
      }.to raise_error
    end

    it "defaults to sandbox" do
      AtPay::Base.instance_eval do 
        @atpay_public_key = nil
      end

      AtPay::Base.should_receive(:environment=).with(:sandbox)
      AtPay::Base.atpay_public_key
    end
  end
end
