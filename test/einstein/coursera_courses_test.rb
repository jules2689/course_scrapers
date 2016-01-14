require 'test_helper'
require 'net/http'
require 'pry'

class Einstein::CourseraCoursesTest < Minitest::Test
  def test_fetch_gets_all_courses
    mock_requests
    results = Einstein::CourseraCourses.fetch
    assert_equal 200, results.size

    # Assert all results has keys
    assert results.all? { |r| r.key?(:course_title) }
    assert results.all? { |r| r[:link].start_with?(Einstein::CourseraCourses::BASE_URL) }
    assert results.all? { |r| r.key?(:description) }
    assert results.all? { |r| r.key?(:image) }
    assert results.all? { |r| r.key?(:price) }
    assert results.all? { |r| r.key?(:department) }
    assert results.all? { |r| r.key?(:languages) }
    assert results.all? { |r| r.key?(:partners) }
    assert results.all? { |r| r[:provider] == "Coursera" }
  end

  def mock_requests
    fields = Einstein::CourseraCourses.send(:fields)
    includes = Einstein::CourseraCourses.send(:includes)

    request_mock = Object.new
    request_mock_2 = Object.new
    http_mock = Net::HTTP.new(Einstein::CourseraCourses::URL, 443)
    Net::HTTP.expects(:new).with(Einstein::CourseraCourses::URL, 443).twice.returns(http_mock)

    fixture = File.read(File.dirname(__FILE__) + "/../fixtures/coursera_0.txt")
    Net::HTTP::Get.expects(:new).with("/api/courses.v1?fields=#{fields}&includes=#{includes}&start=0").returns(request_mock)
    http_mock.expects(:request).with(request_mock).returns(OpenStruct.new(body: fixture))

    fixture_2 = File.read(File.dirname(__FILE__) + "/../fixtures/coursera_1.txt")
    Net::HTTP::Get.expects(:new).with("/api/courses.v1?fields=#{fields}&includes=#{includes}&start=100").returns(request_mock_2)
    http_mock.expects(:request).with(request_mock_2).returns(OpenStruct.new(body: fixture_2))
  end
end
