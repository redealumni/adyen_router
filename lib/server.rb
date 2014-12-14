adyen_router_path = File.dirname(__FILE__)
$LOAD_PATH.unshift(adyen_router_path) unless $LOAD_PATH.include? adyen_router_path

require 'adyen_router/version'
require 'adyen_router/machine'
require 'yaml'
require 'sinatra/base'
require 'base64'
require 'net/http'

module AdyenRouter
  class Server < Sinatra::Base

  @@machines = []

  helpers do
    def protected!
      return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
    end
    
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['USER'], ENV['PASSWORD']]
    end
  end

  get '/settings' do
    protected!

    html = "<h1>Server settings</h1>"
    html += "<h2> Published Machines </h2>"
    html += "<ol>"
    @@machines.each do |m|
      html += "<li>name: #{m.name}<br>host: #{m.host}<br>port: #{m.port}<br></li>"
    end
    html += "</ol>"
    erb html
  end
  
  post '/publish' do
    machine = AdyenRouter::Machine.new *::Base64::decode64(params[:machine]).split("|")
    if @@machines.detect { |published_machine| published_machine.name.eql?(machine.name)}
      @@machines.map! do |published_machine|
        if published_machine.name.eql?(machine.name)
          machine
        else
          published_machine
        end
      end
    else
      @@machines << machine
    end
    [200, {},"AdyenRouter: Yay! Notifications for #{machine.name} will be forward to #{machine.host}:#{machine.port}\n"]
  end

  post '/adyen/post_back' do
  
    protected!

    machine = fetch_machine(params[:merchantReference].scan(/[dev|test]-(.*)::/).flatten.first.to_s)

    puts machine.inspect
    uri = URI("http://#{machine.host}:#{machine.port}/adyen/post_back")

    post_back_proxy = ::Net::HTTP::Post.new(uri, intercept_headers)
    post_back_proxy.set_form_data params

    response = ::Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(post_back_proxy)
    end

    case response
    when ::Net::HTTPSuccess
      [200, {}, response.body]
    else
      halt 404, "not available"
    end

  end


  private

  def fetch_machine(name)
    if machine = @@machines.detect { |m| m.name.eql?(name) }
      return machine
    else
      halt 500, "AdyenRouter - machine #{name} not found"
    end
  end

  def intercept_headers
    { 
      'VERSION' => env['HTTP_VERSION'], 
      'AUTHORIZATION' => env['HTTP_AUTHORIZATION'], 
      'USER_AGENT' => env['HTTP_USER_AGENT']
    }
  end

  # start the server if ruby file executed directly
    run! if app_file == $0
  end


end
