require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
# require 'open-uri'
require 'hpricot'

class Vistr

  def initialize
    @uri = URI.parse("https://vista.csus.ct.edu/webct")
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

  def url_for(path)
    return "#{@uri}/#{path}"
  end

  def post(path, data = {})
    url = URI.parse(url_for(path))
    
    req = Net::HTTP::Post.new url.path
    req.set_form_data data
    
    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true
    
    result = http.request(req)
    
    result.body
  end

  def get(path = nil, options = {})
    perform_request(options) { Net::HTTP::Get.new(url_for(path)) }
  end
  
  def perform_request(options = {}, &block)
    @request = prepare_request(yield, options)
    http = @http.new(uri.host, uri.port)
    @response = returning http.request(@request)
  end
  
  def flatten(params)
    params = params.dup
    params.stringify_keys!.each do |k,v| 
      if v.is_a? Hash
        params.delete(k)
        v.each {|subk,v| params["#{k}[#{subk}]"] = v }
      end
    end
  end

end
