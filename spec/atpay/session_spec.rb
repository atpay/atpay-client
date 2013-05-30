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
      :email => "james@example.com").to_s.should_not be_empty
  end

  it "Generates site token" do
    session.security_key(:amount => 20.00, 
      :card => "test").site_token("0.0.0.0", {
      "HTTP_USER_AGENT" => "0",
      "HTTP_ACCEPT_LANGUAGE" => "1",
      "HTTP_ACCEPT_CHARSET" => "2"
    }).should_not be_empty
  end

  it "Generates multiple security keys" do
    session.security_key(:amount => [20.00, 30.00],
      :email => "james@example.com").length.should eq(2)
  end

  it "Returns a box and caches it" do
    session.boxer.object_id.should eq(session.boxer.object_id)
  end
end
