require 'rubygems'
require 'mechanize'
require 'logger'
require 'course'

class Vistr
  
  def initialize
    @url = "vista.csus.ct.edu/webct"
    @agent = WWW::Mechanize.new { |agent| 
      agent.log = Logger.new("vistr.log")
      agent.follow_meta_refresh = true
    }
  end
  
  def login username, password    
    page = @agent.post(vista_url("authenticateUser.dowebct",true),
                      'glcid'           => "URN:X-WEBCT-VISTA-V1:21fcd19f-0a62-04bb-0011-18e6329eb151",
                      'insId'           => "129143011",
                      'gotoid'          => "null",
                      'insName'         => "Southern+Connecticut+State+University",
                      'timeZoneOffset'  => '4',
                      'webctid'         => "#{username}",
                      'password'        => "#{password}")
  end
  
  def course_list
    courses = Array.new
    course_id_regex = /\/webct\/urw\/(\S*)\//
    
    page = @agent.get vista_url("populateMyWebCT.dowebct")
    
    page.search("//ul[@class='courselist']/li/a").each do |link|
      if link.content.length > 0 && course_id_regex.match(link['href'])
        course = Course.new link.content, 
                            course_id_regex.match(link['href']).captures[0]
                            
        courses << course
      end
    end
    
    courses
  end
  
  def find_course_by_name(course_name)
    course_regex = Regexp.new(course_name)
    
    course_list.each do |course|
      return course if course.name[course_regex]
    end
    
    nil
  end
  
  def assignments
    courses = course_list
    assignments = Array.new
    
    courses.each do |course|
      assignments << course_assignments(course.name)
    end
    
    assignments.compact
  end
  
  def course_assignments(course_name)
    course = find_course_by_name(course_name)
    assignments = Array.new

    course_page = @agent.get vista_url("urw/#{course.id}/studentViewSubmissions.dowebct?viewType=INBOX")
    
    course_page.search("//table[@class='inventorytable']//a[@title='Edit']").each do |link|
      due = /\(Due([^\)]*)/.match(link.parent.parent.search("//div[@class='descript']").first.content.gsub("\n","")).captures[0]
      assignments << [link.content.strip, due] if link.content.length > 0
    end
    
    assignments if assignments.length > 0
  end
  
  private
  
  def vista_url(path, ssl=false)
    if ssl
      "https://#{@url}/#{path}"
    else
      "http://#{@url}/#{path}"
    end
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