require_relative 'live_helper'

# The what's on page: one request.
class LiveIntegrationTest < Minitest::Test
  include LiveHelper

  def test_the_cinema_has_performances_months_ahead
    today = Date.today
    performances = PrincecharlesUk::Performance.at('PRILON', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(PrincecharlesUk::Performance) })
    assert_operator performances.count, :>, 100
    assert_operator performances.map(&:showing_on).max, :>, today + 60
    assert(performances.filter_map(&:booking_url).all? { |url| url.match?(ApiShapes::BOOKING_URL) })
  end
end
