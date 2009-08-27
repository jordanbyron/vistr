#
#  vista.rb
#  
#
#  Created by Jordan Byron on 8/26/09.
#  Copyright (c) 2009 Duck Soup Software. All rights reserved.
#

require 'rubygems'
require 'uri'
require 'net/http'
# require 'open-uri'
require 'hpricot'

class Vistr

  def initialize
    @uri = URI.parse("http://vista.csus.ct.edu/webct")
  end
  
  def login username, password
    @username = username
    result = post("logonHelp.dowebct", :loginDisplay => true, 
    :glcid => "URN:X-WEBCT-VISTA-V1:21fcd19f-0a62-04bb-0011-18e6329eb151",
    :insID => "129143011",
    :gotoid => "null",
    :insName => "Southern Connecticut State University",
    :webctid => username,
    :password => password)
  end

  def url_for(path)
    return "#{@uri}/#{path}"
  end

  def post(path, data = {})
    Net::HTTP.post_form URI.parse(url_for(path)), data
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
