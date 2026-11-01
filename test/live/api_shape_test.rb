require_relative 'live_helper'

# The what's on page: one request.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes
  include LiveHelper

  def test_whats_on_is_readable
    today = TZInfo::Timezone.get('Europe/London').now.to_date

    assert_whats_on_shape(PrincecharlesUk::Internal::Website.new.whats_on, today: today)
  end
end
