require 'helper'

describe AtPay::Session do
  it "Uses the configuration options" do
    AtPay::Config.any_instance.should_receive(:initialize).with({})
    AtPay::Session.new({})
  end

  it "Generates security key" do
    session = AtPay::Session.new({
      :partner_id => partner_id,
      :private_key => private_key,
      :public_key => public_key,
      :environment => :sandbox
    })

    session.security_key(:amount => 20.00, 
      :email => "james@example.com").should_not be_empty
  end
end
