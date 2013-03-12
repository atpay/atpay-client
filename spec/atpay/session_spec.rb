require 'helper'

describe AtPay::Session do
  let(:session) {
    AtPay::Session.new({
      :partner_id => partner_id,
      :private_key => private_key,
      :public_key => public_key,
      :environment => :sandbox
    })
  }

  it "Uses the configuration options" do
    AtPay::Config.any_instance.should_receive(:initialize).with({})
    AtPay::Session.new({})
  end

  it "Generates security key" do
    session.security_key(:amount => 20.00, 
      :email => "james@example.com").should_not be_empty
  end

  it "Generates multiple security keys" do
    session.security_key(:amount => [20.00, 30.00],
      :email => "james@example.com").length.should eq(2)
  end
end
