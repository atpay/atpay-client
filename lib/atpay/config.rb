require 'base64'

module AtPay
  class Config
    class << self 
      def base64_decoding_attr_accessor(*names)
        names.each do |name|
          attr_reader name

          define_method "#{name}=" do |v|
            instance_variable_set("@#{name}", Base64.decode64(v))
          end
        end
      end
    end

    attr_reader :partner_id

    base64_decoding_attr_accessor :private_key, 
      :public_key,
      :atpay_private_key,
      :atpay_public_key

    def initialize(options)
      options.each do |k,v|
        self.send("#{k.to_s}=", v)
      end

      unless options[:environment] or (atpay_private_key and atpay_public_key)
        self.environment = :sandbox
      end
    end

    def partner_id=(v)
      @partner_id = v
    end

    def environment=(v)
      @environment = v

      raise ValueError unless [:production, :sandbox, :test].include? v

      @atpay_public_key = Base64.decode64({
        production: "QZuSjGhUz2DKEvjule1uRuW+N6vCOoMuR2PgCl57vB0=",
        sandbox: "x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18=",
        development: "x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18=",
        test: '8LkeQ7BDO8+e+WRFLWV6Ac4Aq8Ev0odtWOiR1adDYyI='
      }[v])

      if @environment == :test
        @atpay_private_key ||= Base64.decode64('bSyQWtGrWsYfJSZisrZ5eKHKcjtZQv1RO299tJ9bqIg=')
      end
    end
  end
end
