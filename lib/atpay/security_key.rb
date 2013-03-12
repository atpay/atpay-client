require 'rbnacl'
require 'base64'
require 'securerandom'

module AtPay
  class SecurityKey
    def initialize(session, options)
      raise ArgumentError.new("email") unless options[:email] =~ /.+@.+/
      raise ArgumentError.new("amount") unless options[:amount].is_a? Float
  
      @session = session
      @options = options
    end

    def to_s
      "@#{Base64.encode64([nonce, partner_frame, body_frame].join)}"
    ensure
      @nonce = nil
    end

    private
    def partner_frame
      [@session.config.partner_id].pack("Q>")
    end

    def body_frame
      boxer = Crypto::Box.new(@session.config.atpay_public_key, @session.config.private_key)
      boxer.box(nonce, crypted_frame)
    end

    def crypted_frame
      [@options[:email], options_group, "/", options_frame].flatten.compact.join
    end

    def options_frame
      [@options[:amount], expires].pack("g l>")
    end

    def options_group
      ":#{@options[:group]}" if @options[:group]
    end

    def expires
      @options[:expires] || (Time.now.to_i + 3600 * 24 * 7)
    end

    def nonce
      @nonce ||= SecureRandom.random_bytes(24)
    end
  end
end
