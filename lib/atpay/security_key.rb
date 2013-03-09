require 'nacl'
require 'base64'
require 'securerandom'

module AtPay
  class SecurityKey
    def initialize(options)
      raise ValueError unless options[:email] =~ /.+@.+/
      raise ValueError unless options[:amount].is_a? Float

      @options = options
    end

    def to_s
      "@#{Base64.encode64([nonce, partner_frame, body_frame].join)}"
    ensure
      @nonce = nil
    end

    private
    def partner_frame
      [AtPay::Base.partner_id].pack("Q>")
    end

    def body_frame
      NaCl.crypto_box(crypted_frame, nonce, AtPay::Base.atpay_public_key, AtPay::Base.private_key)
    end

    def crypted_frame
      [@options[:email], "/", options_frame].join
    end

    def options_frame
      [@options[:amount], expires].pack("g l>")
    end

    def expires
      @options[:expires] || (Time.now.to_i + 3600 * 24 * 7)
    end

    def nonce
      @nonce ||= SecureRandom.random_bytes(NaCl::BOX_NONCE_LENGTH)
    end
  end
end
