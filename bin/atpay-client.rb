$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'atpay'
require 'yaml'


class Arguments
  attr_reader :values

  def initialize
    @values = YAML.load_file(File.expand_path('../../config/credentials.yml', __FILE__))
  end
end

module Usage
  USAGE = <<-EOS

    The @Pay Client will generate @Pay Tokens for you.  You can use this tool to generate both email
    and site tokens.  There are quite a few arguments but only a handfull are required:


    Examples:
      ruby atpay-client.rb email_token targets bob@bob.com amount 8.0 expires 1454673223
      ruby atpay-client.rb email_token targets bob@bob.com group "8.0 9.5 23.28"


    Required:
      site_token|email_token    You must specify the type of token you wish to generate
      cards|targets             You must at least specify a card or email address.  For a site token
                                you must provide a card.  If you are building multiple tokens ensure
                                that you provide a card token for each email and that the order is
                                correct.
      amount|group              You also need to specify either a single amount or a group of amounts.


    Required (for site token):
      headers                   The request header values for HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE
                                and HTTP_ACCEPT_CHARSET
      addr                      The IP address corresponding to the requesting source (The user's IP)


    Optional:
      expires                   This is the expiration date.  This should be an integer value of
                                seconds since epoch.

  EOS
end


class ClientRunner
  OPTIONS = %w(expires group amount)
  HEADERS = %w(HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE HTTP_ACCEPT_CHARSET)
  EMAIL = /[\w\d\.]+@[\w\.]+[\w]+/
  CARD = /.*=$/

  def initialize(args)
    @config = Arguments.new
    @session = AtPay::Session.new(@config.values)
    @options = {}
    @site_params = [{}]
    @targets = []

    parse args
  end

  # Parse our arguments for all of our values
  def parse(args)
    OPTIONS.each do |option|
      @options[option.to_sym] = args[args.index(option) + 1] unless args.grep(option).empty?
    end

    site_params args
    convert_amounts
    convert_expiration
    get_emails args
    get_cards args
  end

  # Build our list of email addresses to generate tokens for
  def get_emails(args)
    args[args.index('targets') + 1].split(' ')[0].match(EMAIL) ? @options[:email] = args[(args.index('targets') + 1)].split(' ') : @options[:email] = File.read(args[args.index('targets') + 1]).split("\n")
  end

  # Grab all the card tokens
  def get_cards(args)
    args[args.index('cards') + 1].split(' ')[0].match(CARD) ? @options[:card] = args[(args.index('cards') + 1)].split(' ') : @options[:card] = File.read(args[args.index('cards') + 1]).split("\n")
  end

  # Need expiration as an integer
  def convert_expiration
    @options[:expires] = @options[:expires].to_i if @options[:expires]
  end

  # Convert any amounts to floats.
  def convert_amounts
    @options[:amount] = @options[:amount].to_f if @options[:amount]
    @options[:amount] = @options[:group].split(' ').map(&:to_f) if @options[:group]

    @options.delete :group
  end

  # Check our input for site params.
  def site_params(args)
    return if args.grep('addr').empty? or args.grep('headers').empty?

    @site_params[1] = args[args.index('addr') + 1]

    args[args.index('headers') + 1].split(' ').each_with_index { |header, index| @site_params[0][HEADERS[index]] = header }
  end

  # Generate multiple site tokens
  def site_tokens
    options = @options.clone

    @options[:card].each_with_index do |card, index|
      options[:card] = card
      options[:email] = @options[:email][index]

      site_token options
    end
  end

  # Generate a site token
  def site_token(options = @options)
    if options[:card].is_a? Array
      site_tokens
      return
    end

    keys = security_key(options)

    if keys.is_a? Array
      puts keys.map { |key| key.site_token @site_params[1], @site_params[0] }
    else
      puts keys.site_token @site_params[1], @site_params[0]
    end
  end

  # Generate multiple email tokens
  def email_tokens
    options = @options.clone

    @options[:email].each_with_index do |email, index|
      options[:email] = email
      options[:card] = @options[:card][index] if @options[:card]

      email_token options
    end
  end

  # Generate an email token
  def email_token(options = @options)
    if options[:email].is_a? Array
      email_tokens
      return
    end

    keys = security_key(options)

    if keys.is_a? Array
      puts keys.map { |key| key.email_token }
    else
      puts keys.email_token
    end
  end

  # Get a security key object we can ask to generate keys for us.
  def security_key(options = @options)
    @session.security_key(options)
  end
end


operation = ARGV[0]
arguments = ARGV[1..-1]

unless operation
  puts Usage::USAGE
  exit
end

unless arguments.length > 0 and arguments.length % 2 == 0
  puts Usage::USAGE
  exit
end

runner = ClientRunner.new arguments

runner.send operation