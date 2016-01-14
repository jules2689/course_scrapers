require 'test_helper'
require 'mechanize'

class Einstein::MitOpenCourseWareTest < Minitest::Test
  def test_fetch_gets_all_courses
    mock_requests
    results = Einstein::MitOpenCourseWare.fetch
    assert_equal 79, results.size

    # MIT Specific
    assert results.all? { |r| r.key?(:course_code) }
    assert results.all? { |r| r.key?(:level) }
    assert results.all? { |r| r.key?(:syllabus_link) }

    # General
    assert results.all? { |r| r.key?(:course_title) }
    assert results.all? { |r| r[:link].start_with?("http://ocw.mit.edu") }
    assert results.all? { |r| r.key?(:image) }
    assert results.all? { |r| r.key?(:department) }
    assert results.all? { |r| r.key?(:description) }
    assert results.all? { |r| r[:provider] == "MIT" }
  end

  def mock_requests
    fixture = File.read(File.dirname(__FILE__) + "/../fixtures/mit_course.html")
    stub_request(:get, /#{Einstein::MitOpenCourseWare::URL}\/courses|resources\/.*/).to_return(body: fixture, headers: { 'Content-Type' => 'text/html' })

    fixture = File.read(File.dirname(__FILE__) + "/../fixtures/mit_0.html")
    stub_request(:get, "#{Einstein::MitOpenCourseWare::URL}/courses/index.htm").to_return(body: fixture, headers: { 'Content-Type' => 'text/html' })
  end
end
