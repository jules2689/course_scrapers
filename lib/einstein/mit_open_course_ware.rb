require 'mechanize'

# TODO: Use Last Modified and ETags to determine necessity to update
# TODO: ActiveRecord integration

class Einstein::MitOpenCourseWare
  URL = "http://ocw.mit.edu"

  def self.fetch
    course_listings = fetch_course_listings
    course_listings.each_with_index do |(department, courses), idx|
      puts "\n(#{idx + 1} of #{course_listings.size}) Fetching #{courses.size} courses for #{department} at #{DateTime.now}..."
      course_listings[department] = courses.collect.with_index do |course, index| 
        print "\r#{percent(index + 1, courses.size)}%"
        fetch_course_listing(course)
      end
    end
    course_listings
  end

  # Main Course Listings

  def self.fetch_course_listings
    course_hash = {}

    agent.get(URL + "/courses/index.htm") do |page|
      departments = page.search(".deptTitle")
      course_tables = page.search("table.courseList")
      course_listings = departments.zip(course_tables)

      course_listings.each do |listing|
        department = listing.first.text.strip
        courses = listing.last.children.css("tbody tr").collect { |course| extract_course_from_main_listing(course) }          
        course_hash[department] = courses
      end
    end

    course_hash
  end

  def self.extract_course_from_main_listing(course)
    attrs = course.children.map(&:text).map(&:strip).reject { |i| i == "" }
    link = course.css("a").first.attribute("href").value

    {
      course_code: attrs.first,
      course_title: attrs[1].gsub(/\s{2,}/,' '),
      level: attrs.last,
      link: URL + link
    }
  end

  # Individual Course Listing

  def self.fetch_course_listing(course)
    agent.get(course[:link]) do |page|
      description = page.at('meta[@name="Description"]/@content').value.strip
      image = URL + page.search(".image img").first.attribute("src").value
      syllabus_link = page.search("#course_nav a").reject { |a| a.text.strip.downcase != "syllabus" }.first
      
      course[:description] = description
      course[:image] = image
      course[:syllabus_link] = URL + syllabus_link.attribute("href").value if syllabus_link
    end
    course
  end

  # Helpers

  def self.percent(x,y)
    x.to_f / y.to_f * 100.0
  end

  def self.agent
    @agent ||= Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  end

end
