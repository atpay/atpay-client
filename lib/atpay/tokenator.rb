module AtPay
  class Tokenator
    attr_reader :token, 
      :payload,
      :partner_id, 
      :source, 
      :amount, 
      :expires, 
      :group,
      :site_frame,
      :ip,
      :user_data

    TARGETS = {
      /url<(.*?)>/ => [:@url, 6],
      /card<(.*?)>/ => [:@card, 7],
      /email<(.*?)>/ => [:@email, 8],
      /member<(.*?)>/ => [:@member, 9]
    }

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
      # NOTE: This is really for internal use by @Pay.
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
      { email: @email, card: @card, member: @member, url: @url }
    end

    # Return parts in a hash structure, handy for ActiveRecord.
    def to_h
      {
        sale_price: @amount,
        expires_at: Time.at(Time.now + @expires),
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
        RbNaCl::Box.new(key, @session.config.atpay_private_key)
      else
        RbNaCl::Box.new(key, ENCRYPTION[:security_key_sec])
      end
    end

    # Decrypt the payload.
    def payload(nonce, key, decoded)
      @payload = boxer(key).open(nonce, decoded)
    end

    # Break the payload out into it's constituent logical parts.
    def part_out_payload
      # TARGET:GROUP/AMOUNTEXPIRATION/USERDATA
      # TARGET:GROUP/AMOUNTEXPIRATION
      # TARGET:/AMOUNTEXPIRATION (?)
      # TARGET/AMOUNTEXPIRATION/USERDATA
      # TARGET/AMOUNTEXPIRATION
      if @payload.match '>:'
        raw_target, @group = @payload.split('>:', 2)
        raw_target += '>'
      else
        raw_target = @payload
      end

      target raw_target

      if @group
        @group = @payload.slice!(0, @group.index("/")) 
        @payload.slice!(0, 1)
      end
      
      @amount = parse_amount!
      @expiration = parse_expiration!
      @user_data = parse_user_data!
    end

    def parse_amount!
      @amount = @payload.slice!(0, 4).unpack("g")[0].round(2)
    end

    def parse_expiration!
      @expires = @payload.slice!(0, 4).unpack("l>")[0]
    end

    def parse_user_data!
      @user_data = @payload[1..-1]
      @payload = nil
      return @user_data
    end

    # Find the target of the token.  This could be a Credit Card,
    # Email Address, URL or Member UUID.
    def target(target)
      match = TARGETS.keys.detect { |key| target.match key }

      raise "No target found" if match.nil?

      instance_variable_set TARGETS[match][0], $1.dup
      @payload.slice!(0, ($1.length + TARGETS[match][1]))
    end
  end
end
