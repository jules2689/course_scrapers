require 'test_helper'
require 'json'
require 'net/http'

class Einstein::HarvardOpenCourseWareTest < Minitest::Test
  def test_fetch_gets_all_courses
    VCR.use_cassette("harvard_open_course_ware") do
      capture_subprocess_io do
        results = Einstein::HarvardOpenCourseWare.fetch
        assert_equal 231, results.size

        # Assert all results has keys
        assert results.all? { |r| r.key?(:course_title) }
        assert results.all? { |r| r[:link].start_with?("http://online-learning.harvard.edu/course/") }
        assert results.all? { |r| r.key?(:image) }
        assert results.all? { |r| r.key?(:price) }
        assert results.all? { |r| r.key?(:department) }
        assert results.all? { |r| r[:provider] == "Harvard" }
      end
    end
  end
end
