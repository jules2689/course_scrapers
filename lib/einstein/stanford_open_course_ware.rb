require 'mechanize'

# TODO: Use Last Modified and ETags to determine necessity to update
# TODO: ActiveRecord integration

class Einstein::StanfordOpenCourseWare
  URL = "http://online.stanford.edu"
  PROVIDER = "Stanford"

  def self.fetch
    courses = []

    # Fetch the Index Page
    # The Index Page contains most of the information needed, including course title, link, department, etc
    agent.get(URL + "/courses/allcourses") do |page|
      course_tables = page.search("table.views-table")
      course_tables.each do |course_table|
        courses << extract_course_from_course_table(course_table)
      end
      courses.flatten!
    end

    # Fetch each course page
    courses = courses.collect.with_index do |course, index|
      puts "Fetching course #{index + 1} of #{courses.size}"
      fetch_course_listing(course)
    end

    courses
  end

  # Main Course Listings

  def self.extract_course_from_course_table(course_table)
    rows = course_table.css('tbody tr')
    rows.collect do |row|
      {
        course_code: "",
        course_title: row.css('td.views-field-title a').text.strip,
        level: "",
        link: URL + row.css('td.views-field-title a').attribute('href').value,
        department: row.css('td.views-field-field-department a').text.strip,
        provider: PROVIDER
      }
    end
  end

  # Individual Course Listing

  def self.fetch_course_listing(course)
    agent.get(course[:link]) do |page|
      description = page.search('.pane-content').inner_html.strip
      image = page.search(".field-name-field-homepage-feature-image img").first
      course[:description] = description
      course[:image] = image.attribute("src").value unless image.nil?
    end
    course
  end

  # Mechanize Agent

  def self.agent
    @agent ||= Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  end
end
