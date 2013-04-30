require 'atpay/config'
require 'atpay/security_key'

module AtPay
  class Session
    attr_accessor :config

    def initialize(options)
      @config = Config.new(options)
    end

    def security_keys(options)
      options = options.clone
      
      options[:group] ||= "#{SecureRandom.uuid.gsub("-", "")}-#{Time.now.to_i}"

      keys = []

      options[:amount].each do |amount|
        keys << security_key(options.update(:amount => amount))
      end

      keys
    end

    def security_key(options)
      if options[:amount].is_a? Array
        security_keys(options)
      else
        SecurityKey.new(self, options.update(:amount => options[:amount]))
      end
    end
  end
end
