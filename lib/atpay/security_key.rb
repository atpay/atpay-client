require 'rbnacl'
require 'base64'
require 'securerandom'

module AtPay
  class SecurityKey
    def initialize(session, options)
      raise "User Data can't exceed 2500 characters." if options[:user_data] and options[:user_data].length > 2500

      raise ArgumentError.new("email") unless options[:email].nil? or options[:email] =~ /.+@.+/
      raise ArgumentError.new("amount") unless options[:amount].is_a? Float
      raise ArgumentError.new("card or email or member required") if options[:email].nil? and options[:card].nil? and options[:member].nil?
  
      @session = session
      @options = options
    end

    def email_token
      "@#{Base64.strict_encode64([nonce, partner_frame, body_frame].join)}"
    ensure
      @nonce = nil
    end

    def site_token(remote_addr, headers)
      raise ArgumentError.new("card or member required for site tokens") if @options[:card].nil? and @options[:member].nil?
      "@#{Base64.strict_encode64([nonce, partner_frame, site_frame(remote_addr, headers), body_frame].join)}"
    ensure
      @nonce = nil
    end

    def to_s
      email_token
    end

    private
    def partner_frame
      [@session.config.partner_id].pack("Q>")
    end

    def site_frame(remote_addr, headers)
      message = boxer.box(nonce, Digest::SHA1.hexdigest([
        headers["HTTP_USER_AGENT"],
        headers["HTTP_ACCEPT_LANGUAGE"],
        headers["HTTP_ACCEPT_CHARSET"],
        remote_addr
      ].join))

      [[message.length].pack("l>"), message, 
        [remote_addr.length].pack("l>"), remote_addr].join
    end

    def body_frame
      boxer.box(nonce, crypted_frame)
    end

    def crypted_frame
      if user_data = user_data_frame
        [target, options_group, '/', options_frame, '/', user_data].flatten.compact.join
      else
        [target, options_group, "/", options_frame].flatten.compact.join
      end
    end

    def options_frame
      [@options[:amount], expires].pack("g l>")
    end

    def user_data_frame
      @options[:user_data].to_s if @options[:user_data]
    end

    def options_group
      ":#{@options[:group]}" if @options[:group]
    end

    def target
      card_format || member_format || email_format
    end

    def card_format
      "card<#{@options[:card]}>" if @options[:card]
    end

    def member_format
      "member<#{@options[:member]}>" if @options[:member]
    end

    def email_format
      "email<#{@options[:email]}>" if @options[:email]
    end

    def expires
      @options[:expires] || (Time.now.to_i + 3600 * 24 * 7)
    end

    def boxer
      @session.boxer
    end

    def nonce
      @nonce ||= SecureRandom.random_bytes(24)
    end
  end
end
