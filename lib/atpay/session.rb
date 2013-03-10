require 'atpay/config'
require 'atpay/security_key'

module AtPay
  class Session
    attr_accessor :config

    def initialize(options)
      @config = Config.new(options)
    end

    def security_key(options)
      SecurityKey.new(self, options).to_s
    end  
  end
end
