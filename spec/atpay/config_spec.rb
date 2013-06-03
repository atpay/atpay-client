require 'helper'

describe AtPay::Config do
  let(:config) {
    AtPay::Config.new({
      :partner_id     => partner_id,
      :private_key    => private_key,
      :public_key     => public_key,
      :environment    => :sandbox
    })
  }

  describe "overview" do
    it "accepts multiple arguments" do
      AtPay::Config.any_instance.should_receive(:partner_id=).with(partner_id)
      AtPay::Config.any_instance.should_receive(:private_key=).with(private_key)
      AtPay::Config.any_instance.should_receive(:public_key=).with(public_key)
      AtPay::Config.any_instance.should_receive(:environment=).with(:sandbox)

      AtPay::Config.new({
        :partner_id     => partner_id,
        :private_key    => private_key,
        :public_key     => public_key,
        :environment    => :sandbox
      })
    end
  end

  describe "values" do
    it "accepts partner id" do
      config.partner_id = partner_id
      config.partner_id.should eq(partner_id)
    end

    it "accepts private key" do
      config.private_key = private_key
      config.private_key.should_not be_empty
    end

    it "accepts public key" do
      config.public_key = public_key
      config.public_key.should_not be_empty
    end

    it "accepts environment" do
      config.environment = :sandbox
      config.atpay_public_key.should_not be_empty
    end
  end

  describe "environment" do
    it "required to be production or sandbox" do
      expect {
        AtPay::Config.new :environment => :none
      }.to raise_error
    end

    it "defaults to sandbox" do
      AtPay::Config.any_instance.should_receive(:environment=).with(:sandbox)
      config = AtPay::Config.new({})
    end
  end
end
