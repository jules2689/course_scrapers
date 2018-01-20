# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'json'
require 'uri'

# TODO: Use Last Modified and ETags to determine necessity to update
# TODO: ActiveRecord integration

class Einstein::HarvardOpenCourseWare
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

    # Fetch Results
    url = "#{BASE_URL}/ajax/more_courses?offset=#{offset}"
    response = Net::HTTP.get(URI(url))
    json = JSON.parse(response)
    courses = []
    new_offset = json["offset"]

    # We know we're done if the html in the json is &nbsp;
    # Take each of the course inner items, which contain course info
    # And Parse the infromation
    if json["html"] != "&nbsp;"
      page = Nokogiri::HTML(json["html"])
      courses << page.css(".course-item-inner").collect do |course|
        extract_course_from_main_listing(course)
      end
    else
      new_offset = -1 # We have no more results so set the offset to -1
    end

    { offset: new_offset, courses: courses.flatten }
  end

  # Use Nokogiri to extract information from the HTML.
  # Each result is an array, take the first from each
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
