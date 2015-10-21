require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require_relative 'avobject'

# avcloud interface
class AVCloud
  def initialize app_id, app_key
    @base_url = "https://leancloud.cn/1.1"
    @user = nil
    
    @app_id = app_id
    @app_key = app_key
    raise "please set app_id and app_key" if @app_id.nil? or @app_key.nil?
  end

  def has_login
    return @user.nil?
  end

  def current_user
    return @user
  end

  def logout
    @user = nil
  end
  
  def login username, password
    # init and clear @user
    @user = nil
    
    uri = URI.parse("#{@base_url}/login")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    headers = {
      "X-LC-Id" => @app_id,
      "X-LC-Key" => @app_key,      
    }
    data = {
      "username" => username,
      "password" => password,
    }
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    request.set_form_data(data)
    response = http.request(request)
    user =  AVUser.new response.body
    if user.error? then
      raise "login failed"
    else
      puts "login success!"
      @user = user
    end    
  end

  def get_user object_id
    data = get_object_impl "#{@base_url}/users/#{object_id}"
    AVUser.new(data)
  end
  
  def get_object class_name, object_id
    data = get_object_impl "#{@base_url}/classes/#{class_name}/#{object_id}"
    AVResult.new(data)
  end
  
  def get_objects class_name
    data = get_object_impl "#{@base_url}/classes/#{class_name}"
    AVResult.new(data)
  end

  private
  def get_object_impl url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    headers = {
      "X-LC-Id" => @app_id,
      "X-LC-Key" => @app_key,
      "X-LC-Session" => @user.session_token,
    }
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    response = http.request(request)
    response.body
  end   
end

