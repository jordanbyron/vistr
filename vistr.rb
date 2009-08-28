require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
# require 'open-uri'
require 'hpricot'
require 'activesupport'

class Vistr
  attr_accessor :cookie
  
  def initialize
    @uri = URI.parse("vista.csus.ct.edu/webct")
    @http = Net::HTTP
  end
  
  def login username, password
    @username = username
    result = post("authenticateUser.dowebct", 'loginDisplay' => 'true', 
    'glcid' => "URN:X-WEBCT-VISTA-V1:21fcd19f-0a62-04bb-0011-18e6329eb151",
    'insID' => "129143011",
    'gotoid' => "null",
    'insName' => "Southern Connecticut State University",
    'timeZoneOffset' => '4',
    'webctid' => "#{username}",
    'password' => "#{password}")
  end
  
  def course_list
    get "manageCourseList.dowebct"
  end

  def url_for(path, options={})
    url = "#{@uri}/#{path}"
    
    if options[:use_ssl]
      url = "https://#{url}" 
    else
      url = "http://#{url}"
    end
    
    return url
  end

  private

    def post(path, data = {})
      url = URI.parse(url_for(path, :use_ssl => true))
      
      req = Net::HTTP::Post.new url.path
      req.set_form_data data
      
      http = Net::HTTP.new(url.host,url.port)
      http.use_ssl = true
      
      response = http.request(req)
      
      @cookie = response['set-cookie'] if response['set-cookie']
      
      response
    end

    def get(path = nil, options = {})
      url = URI.parse(url_for(path))
      
      request = Net::HTTP::Get.new url.path
      request.add_field 'Cookie', @cookie if @cookie
      
      http = Net::HTTP.new(url.host,url.port)
      
      response = http.request(request)
    end

end