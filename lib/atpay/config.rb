require 'base64'

module AtPay
  class Config
    attr_reader :partner_id, 
      :private_key, 
      :public_key

    def initialize(options)
      options.each do |k,v|
        self.send("#{k.to_s}=", v)
      end
    end

    def atpay_public_key
      if @atpay_public_key.nil?
        self.environment = :sandbox
      else
        @atpay_public_key
      end 
    end

    def partner_id=(v)
      @partner_id = v
    end

    def private_key=(v)
      @private_key = Base64.decode64(v)
    end

    def public_key=(v)
      @public_key = Base64.decode64(v)
    end

    def environment=(v)
      @environment = v

      raise ValueError unless [:production, :sandbox, :test].include? v

      @atpay_public_key = Base64.decode64({
        :production => "QZuSjGhUz2DKEvjule1uRuW+N6vCOoMuR2PgCl57vB0=",
        :sandbox => "x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18=",
        :test => '8LkeQ7BDO8+e+WRFLWV6Ac4Aq8Ev0odtWOiR1adDYyI='
      }[v])

      if @environment == :test
        @atpay_private_key = 'bSyQWtGrWsYfJSZisrZ5eKHKcjtZQv1RO299tJ9bqIg='
        AtPay::Config.define_method(:atpay_private_key) { @atpay_private_key }
      end
    end
  end
end
