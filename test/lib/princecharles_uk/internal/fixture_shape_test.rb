require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_whats_on_fixture_matches_shape
    assert_whats_on_shape(whats_on_html, today: FIXTURE_DAY)
  end
end
