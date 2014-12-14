require "adyen_router/version"
require 'open-uri'
require 'net/http'
require 'base64'

module AdyenRouter
 
    def self.configure(&block)
      @client = Client.new
      @client.instance_eval &block
      @client.publish
    end

  class Client

    attr_writer   :identity, :host, :port
    attr_accessor :use_private_address, :remote_address

    def identity
      @identity ||= Socket.gethostname
    end

    def host
      if !@host.nil?
        @host
      elsif local_network?
        Socket.ip_address_list.detect {|ip| ip.ipv4_private? }.ip_address
      else
        public_ip_address
      end
    end

    def port
      @port ||= 3000
    end

    def local_network?
      use_private_address
    end

    def public_ip_address
      begin
        remote_ip = open('http://whatismyip.akamai.com').read
      rescue Exception => e
        puts 'Service down or unavailable! Trying to use the provided ip address'
        raise 'Could not find a valid host! Have you tried setting your own?'
      end
    end

    def publish
      protocol = remote_address.scan(/(http):\/\/|(https):\/\//).flatten.compact.first
      remote_address.gsub!(/http:\/\/|https:\/\//, '')
      protocol = "http" unless protocol
      uri = URI("#{protocol}://#{remote_address}/publish")

      req = Net::HTTP::Post.new(uri)
      req.set_form_data(machine: Base64.encode64("#{identity}|#{host}|#{port}"))

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      puts res.body

    end

  end
end
