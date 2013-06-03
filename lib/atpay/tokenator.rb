module AtPay
  class Tokenator
    attr_reader :token, :payload, :source, :amount, :expires, :user_data

    # A bit clunky but useful for testing token decomposition.
    # If you provide a test session then the config values there 
    # will be used so that decryption will function without @Pay's
    # private key.
    def initialize(token, session = nil)
      @token = token
      @session = session
      strip_version

      @checksum = Digest::SHA1.hexdigest(token) # Before or after removing version?
    end

    class << self
      # Get the version of the given token.
      def token_version(token)
        token.scan('-').empty? ? 0 : unpack_version(token.split('-')[0])
      end

      # Check and make sure we haven't seen this token before.
      def find_by_checksum(token)
        checksum = Digest::SHA1.hexdigest(token)

        SecurityKey.find_by_encoded_key(checksum) || ValidationToken.find_by_encoded_key(checksum)
      end


      private

      # Unpack the actual version value.
      def unpack_version(version)
        Base64.decode64(version[1..-1]).unpack("Q>")[0]
      end
    end
    

    # We want to pull the header out of the token.  This means we
    # grab the nonce and the partner id from the token.  The version
    # frame should be removed before calling header.
    def header
      decode
      nonce
      destination
    end

    # Here we parse the body of the token.  All the useful shit
    # comes out of this.
    def body(key)
      payload(nonce, key, @token)
      part_out_payload
      unpack
    end

    # With a site token you want to call this after header.  It will
    # pull the ip address and header sha out of the token.
    def browser_data(key)
      length = @token.slice!(0, 4).unpack("l>")[0]
      @site_frame = boxer(key).open(nonce, @token.slice!(0, length))

      length = @token.slice!(0, 4).unpack("l>")[0]
      @ip = @token.slice!(0, length)
    end

    def source
      {email: @email, card: @card, member: @member}
    end

    # Return parts in a hash structure, handy for ActiveRecord.
    def to_h
      {
        sale_price: @amount,
        expires_at: Time.at(@expires),
        group: @group,
        encoded_key: @checksum
      }
    end


    private

    # Strip the version frame from the token.
    def strip_version
      @token = @token.split('-').last
    end

    # Fix our Base64 problems
    def decode
      @token = Base64.decode64 @token 
    end

    # Extract our entropy
    def nonce
      @nonce ||= @token.slice!(0, 24)
    end

    # Find the recipient of the betokened transaction
    def destination
      nonce unless @nonce

      #@partner ||= OpportunityMap.find(@token.slice!(0, 8).unpack("Q>")[0]).opportunity
      @partner_id ||= @token.slice!(0, 8).unpack("Q>")[0]
    end

    def boxer(key)
      if @session
        Crypto::Box.new(key, Base64.decode64(@session.config.atpay_private_key))
      else
        Crypto::Box.new(key, ENCRYPTION[:security_key_sec])
      end
    end

    # Decrypt the payload.
    def payload(nonce, key, decoded)
      @payload = boxer(key).open(nonce, decoded)
    end

    # Break the payload out into it's constituent logical parts.
    def part_out_payload
      if @payload.match ':'
        target @payload.split(':').first
        @group, @amount_expiration, @user_data = frames
      else
        target @payload.split('/').first
        @amount_expiration, @user_data = frames
      end
    end

    # Find all the frame pieces.  However many there may be.
    def frames
      @payload.split('/')
    end

    # Find the target of the token.  This could be a Credit Card
    # Email Address or Member UUID.
    def target(target)
      case target
      when /card<(.*?)>/
        @card = $1
        @payload.slice!(0, ($1.length + 7))
      when /email<(.*?)>/
        @email = $1
        @payload.slice!(0, ($1.length + 8))
      when /member<(.*?)>/
        @member = $1
        @payload.slice!(0, ($1.length + 9))
      else
        raise "No target found"
      end
    end

    # Unpack handles unpacking all the specific frames
    def unpack
      unpack_amount_expiration
    end

    # Unpack the frame containing the amount and expiration value if given.
    def unpack_amount_expiration
      @amount = @amount_expiration.slice!(0, 4).unpack("g")[0]
      @expires = @amount_expiration.slice!(0, 4).unpack("l>")[0]
      #@mappings = @amount_expiration.unpack("Q>" * (packed.length / 8)).collect { |m| OpportunityMap.find(m).opportunity }
    end
  end
end