require 'mechanize'

# TODO: Use Last Modified and ETags to determine necessity to update
# TODO: ActiveRecord integration

class Einstein::MitOpenCourseWare
  URL = "http://ocw.mit.edu"
  PROVIDER = "MIT"

  def self.fetch
    course_listings = fetch_course_listings.flatten
    # After fetching all courses, we need to fetch each one individually to get additional information
    course_listings.collect.with_index do |course, idx|
      puts "\n(#{idx + 1} of #{course_listings.size}) Fetching #{course[:course_title]} at #{DateTime.now}"
      fetch_course_listing(course)
    end
  end

  # Main Course Listings

  def self.fetch_course_listings
    courses = []

    # Fetch the Index Page
    # The Index Page contains most of the information needed, including course title, link, department, etc
    agent.get(URL + "/courses/index.htm") do |page|
      departments = page.search(".deptTitle")
      course_tables = page.search("table.courseList")
      course_listings = departments.zip(course_tables)

      courses << course_listings.collect do |listing|
        department = listing.first.text.strip.gsub(/\s+/, ' ')
        listing.last.children.css("tbody tr").collect { |course| extract_course_from_main_listing(course, department) }
      end
    end

    courses.flatten
  end

  def self.extract_course_from_main_listing(course, department)
    attrs = course.children.map(&:text).map(&:strip).reject { |i| i == "" }
    link = course.css("a").first.attribute("href").value

    {
      course_code: attrs.first,
      course_title: attrs[1].gsub(/\s{2,}/, ' '),
      level: attrs.last,
      link: URL + link,
      department: department,
      provider: PROVIDER
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

  # Mechanize Agent

  def self.agent
    @agent ||= Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  end
end
