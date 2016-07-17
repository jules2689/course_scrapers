require 'test_helper'
require 'mechanize'

class Einstein::MitOpenCourseWareTest < Minitest::Test
  def test_fetch_gets_all_courses
    # we used a bit of a spoofed html form here.
    # MIT has > 3000 requests that would have to be made
    # so we cheated and included 2 departments and only 6 courses
    # in the index html to reduce test time
    VCR.use_cassette("mit_open_course_ware") do
      capture_subprocess_io do
        results = Einstein::MitOpenCourseWare.fetch
        assert_equal 6, results.size

        # MIT Specific
        assert results.all? { |r| r.key?(:course_code) }
        assert results.all? { |r| r.key?(:level) }
        assert results.all? { |r| r.key?(:syllabus_link) }

        # General
        assert results.all? { |r| r.key?(:course_title) }
        assert results.all? { |r| r[:link].start_with?("http://ocw.mit.edu") }
        assert results.all? { |r| r.key?(:image) }
        results[0..2].each do |r|
          assert_equal 'Aeronautics and Astronautics', r[:department]
        end
        results[3..5].each do |r|
          assert_equal 'Anthropology', r[:department]
        end
        assert results.all? { |r| r.key?(:description) }
        assert results.all? { |r| r[:provider] == "MIT" }
      end
    end
  end
end
