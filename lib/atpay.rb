require 'atpay/security_key'
require 'base64'

module AtPay
  class Base
    class << self
      attr_reader :partner_id, 
        :private_key, 
        :public_key

      def config=(options)
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

        raise ValueError unless [:production, :sandbox].include? v

        @atpay_public_key = Base64.decode64({
          :production => "QZuSjGhUz2DKEvjule1uRuW+N6vCOoMuR2PgCl57vB0=",
          :sandbox => "x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18="
        }[v])
      end
    end
  end
end
