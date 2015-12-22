require 'nokogiri'
require 'net/http'
require 'json'

# TODO: Use Last Modified and ETags to determine necessity to update
# TODO: ActiveRecord integration

class Einstein::HarvardOpenCourseWare
  URL = "http://online-learning.harvard.edu/ajax/more_courses/"
  BASE_URL = "http://online-learning.harvard.edu"
  PROVIDER = "Harvard"

  def self.fetch
    offset = 0
    courses = []
    while offset >= 0
      course_hash = fetch_course_listings(offset)
      offset = course_hash[:offset]
      courses << course_hash[:courses]
    end
    courses.flatten
  end

  # Main Course Listings

  def self.fetch_course_listings(offset)
    puts "Fetching with an offset of #{offset}"
    uri = URI(URL + "?offset=#{offset}")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    courses = []
    new_offset = json["offset"]

    if json["html"] != "&nbsp;"
      page = Nokogiri::HTML(json["html"])
      courses << page.css(".course-item-inner").collect do |course|
        extract_course_from_main_listing(course)
      end
    else
      new_offset = -1
    end

    { offset: new_offset, courses: courses.flatten }
  end

  def self.extract_course_from_main_listing(course)
    department = course.css(".category-link").first.text
    title = course.css(".course-title").first.text
    desc = course.css(".course-brief").first.text.strip
    price = course.css(".price").first.text
    image = course.css(".course-image img").first.attribute("src").value
    link = course.css(".course-image-wrapper a").first.attribute("href").value

    {
      course_title: title,
      link: BASE_URL + link,
      description: desc,
      image: image,
      price: price,
      department: department,
      provider: PROVIDER
    }
  end

end
