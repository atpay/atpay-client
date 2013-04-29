$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'atpay'
require 'yaml'
require 'pry'


class Arguments
  attr_reader :values

  def initialize
    @values = YAML.load_file(File.expand_path('../../config/credentials.yml', __FILE__))
  end
end

class Usage
  USAGE = <<-EOS

    The @Pay Client will generate @Pay Tokens for you.  You can use this tool to generate both email
    and site tokens.  There are quite a few arguments but only a handfull are required:


    Examples:
      ruby atpay-client.rb email_token targets bob@bob.com amount 8.0 expires 1454673223
      ruby atpay-client.rb email_token targets bob@bob.com group "8.0 9.5 23.28"


    Required:
      site_token|email_token    You must specify the type of token you wish to generate
      card|targets              You must at least specify a card or email address.  For a site token
                                you must provide a card.
      amount|group              You also need to specify either a single amount or a group of amounts.


    Required (for site token):
      headers                   The request header values for HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE
                                and HTTP_ACCEPT_CHARSET
      addr                      The IP address corresponding to the requesting source (The user's IP)


    Optional:
      expires                   This is the expiration date.  This should be an integer value of
                                seconds since epoch.

  EOS

  def initialize(args)
    
  end
end


class ClientRunner
  OPTIONS = %w(expires group amount card)
  HEADERS = %w(HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE HTTP_ACCEPT_CHARSET)
  EMAIL = /[\w\d\.]+@[\w\.]+[\w]+/

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

    args[args.index('targets') + 1].split(' ')[0].match(EMAIL) ? emails(args[(args.index('targets') + 1)]) : emails(File.read(args[args.index('targets') + 1]))
  end

  # Build our list of email addresses to generate tokens for
  def emails(list)
    list = list.split "\n" unless list.class == Array

    @targets = list
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

  # Generate a site token
  def site_token
    keys = security_key

    if keys.is_a? Array
      puts keys.map { |key| key.site_token @site_params[1], @site_params[0] }
    else
      puts keys.site_token @site_params[1], @site_params[0]
    end
  end

  # Generate an email token
  def email_token
    @options[:email] = @targets[0]

    keys = security_key

    if keys.is_a? Array
      puts keys.map { |key| key.email_token }
    else
      puts keys.email_token
    end
  end

  # Get a security key object we can ask to generate keys for us.
  def security_key
    @session.security_key(@options)
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