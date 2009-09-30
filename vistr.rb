require 'rubygems'
require 'mechanize'
require 'logger'
#require 'vistr/course'

class Vistr
  
  def initialize
    @url = "vista.csus.ct.edu/webct"
    @agent = WWW::Mechanize.new { |agent| 
      agent.log = Logger.new("vistr.log")
      agent.follow_meta_refresh = true
    }
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
  
  def assignments
    courses = course_list
    assignments = Array.new
    
    courses.each do |course|
      assignments << course_assignments(course)
    end
    
    assignments.compact
  end
  
  def course_assignments(course)
    page = @agent.get "http://#{@url}/populateMyWebCT.dowebct"
    course_regex = Regexp.new(course)
    course_id_regex = /\/webct\/urw\/(\S*)\//
    course_id = ""
    assignments = Array.new
    
    page.search("//ul[@class='courselist']/li/a").each do |link|
      course_id = course_id_regex.match(link['href']).captures[0] if link.content[course_regex] && course_id_regex.match(link['href'])
    end

    course_page = @agent.get "http://#{@url}/urw/#{course_id}/studentViewSubmissions.dowebct?viewType=INBOX"
    
    course_page.search("//table[@class='inventorytable']//a[@title='Edit']").each do |link|
      due = /\(Due([^\)]*)/.match(link.parent.parent.search("//div[@class='descript']").first.content.gsub("\n","")).captures[0]
      assignments << [link.content.strip, due] if link.content.length > 0
    end
    
    assignments.compact
  end
end

## FIXME: Use aliasing rather than blowing over the existing method

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