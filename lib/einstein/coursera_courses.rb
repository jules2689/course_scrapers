require 'net/https'

class Einstein::CourseraCourses
  BASE_URL = "https://www.coursera.org/courses/"
  URL = "www.coursera.org"
  PROVIDER = "Coursera"

  def self.fetch
    offset = 0
    courses = []
    while offset >= 0
      result = fetch_course_listings(offset)
      offset = result[:offset]
      courses << result[:courses]
    end
    
    courses.flatten
  end

  private

  def self.fetch_course_listings(offset=0)
    MessageLogger.log "Fetching with an offset of #{offset}"

    # HTTP request
    http = Net::HTTP.new(URL, 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new("/api/courses.v1?fields=#{fields}&includes=#{includes}&start=#{offset}")
    response = http.request(request)

    # Parse the request
    json = JSON.parse(response.body)
    courses = []
    new_offset = json["offset"]

    # Extract all courses
    courses << json["elements"].collect do |course|
      extract_course_from_main_listing(course, json["linked"]["partners.v1"])
    end

    # We know we're done if the paging->next key in the json is nil
    if !json["paging"]["next"].nil?
      new_offset = json["paging"]["next"].to_i
    else
      new_offset = -1 # We have no more results so set the offset to -1
    end

    { offset: new_offset, courses: courses.flatten }
  end

  def self.extract_course_from_main_listing(course, partners)
    {
      course_title: course["name"],
      link: BASE_URL + course["slug"],
      description: course["description"],
      image: course["photoUrl"],
      price: "free",
      department: domains_from_course(course),
      languages: course["primaryLanguages"],
      partners: partners_from_course(course, partners),
      provider: PROVIDER
    }
  end

  def self.domains_from_course(course)
    course["domainTypes"].collect { |domain_type| "#{domain_type["domainId"]}/#{domain_type["subdomainId"]}" }
  end

  def self.partners_from_course(course, partners)
    course["partnerIds"].collect do |partner_id| 
      partner = partners.select { |p| partner_id == p["id"] }.first
      partner["name"]
    end
  end

  def self.fields
    %w(
      photoUrl
      primaryLanguages
      domainTypes
      name
      description
      partnerIds
      specializations
      partners.v1(abbrName,homeLink,name)
      specializations.v1(name)
    ).join(',')
  end

  def self.includes
    %w(
      partnerIds
      specializations
    ).join(',')
  end

end
