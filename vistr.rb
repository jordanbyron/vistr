require 'rubygems'
require 'mechanize'
require 'logger'

class Vistr

  def initialize
    @url = "vista.csus.ct.edu/webct"
    @agent = WWW::Mechanize.new { |a| a.log = Logger.new("vistr.log") }
  end
  
  def login username, password
    page = @agent.post("https://#{@url}/authenticateUser.dowebct",
                      'glcid'           => "URN:X-WEBCT-VISTA-V1:21fcd19f-0a62-04bb-0011-18e6329eb151",
                      'insId'           => "129143011",
                      'gotoid'          => "null",
                      'insName'         => "Southern+Connecticut+State+University",
                      'timeZoneOffset'  => '4',
                      'webctid'         => "#{username}",
                      'password'        => "#{password}")
  end
  
  def course_list
    classes = Array.new
    
    page = @agent.get "http://#{@url}/populateMyWebCT.dowebct"
    
    page.search("//ul[@class='courselist']/li/a").each do |link|
      classes << link.content if link.content.length > 0
    end
    
    classes
  end
end




class WWW::Mechanize::Util
  def self.build_query_string(parameters, enc=nil)
    parameters.map { |k,v|
      if k
        [CGI.escape(k.to_s), dash_escape(CGI.escape(v.to_s))].join("=")
      end
    }.compact.join('&')
  end
  
  def self.dash_escape value
    value.gsub("-","%2D")
  end
end