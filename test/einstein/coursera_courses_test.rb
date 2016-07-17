require 'test_helper'

class Einstein::CourseraCoursesTest < Minitest::Test
  def test_fetch_gets_all_courses
    VCR.use_cassette("coursera_courses") do
      capture_subprocess_io do
        results = Einstein::CourseraCourses.fetch
        assert_equal 1954, results.size

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
    end
  end
end
