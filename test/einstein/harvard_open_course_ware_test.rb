require 'test_helper'
require 'json'
require 'net/http'

class Einstein::HarvardOpenCourseWareTest < Minitest::Test
  def test_fetch_gets_all_courses
    mock_requests
    results = Einstein::HarvardOpenCourseWare.fetch
    assert_equal 12, results.size

    # Assert all results has keys
    assert results.all? { |r| r.key?(:course_title) }
    assert results.all? { |r| r[:link].start_with?("http://online-learning.harvard.edu/course/") }
    assert results.all? { |r| r.key?(:image) }
    assert results.all? { |r| r.key?(:price) }
    assert results.all? { |r| r.key?(:department) }
    assert results.all? { |r| r[:provider] == "Harvard" }
  end

  def mock_requests
    fixture = File.read(File.dirname(__FILE__) + "/../fixtures/harvard_0.txt")
    Net::HTTP.expects(:get).with(Einstein::HarvardOpenCourseWare::BASE_URL, "/ajax/more_courses?offset=0").returns(fixture)

    fixture = File.read(File.dirname(__FILE__) + "/../fixtures/harvard_1.txt")
    Net::HTTP.expects(:get).with(Einstein::HarvardOpenCourseWare::BASE_URL, "/ajax/more_courses?offset=12").returns(fixture)
  end
end
