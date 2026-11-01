require_relative '../../test_helper'

class PrincecharlesUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  BOOKING = 'https://princecharlescinema.com/prince-charles-cinema/booknow/'.freeze

  def setup
    stub_whats_on
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('PRILON')

    assert(performances.all? { |p| p.instance_of?(PrincecharlesUk::Performance) })
    assert_equal 87, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_one_request
    performances = performances_at('prilon')

    assert_equal Date.new(2027, 6, 25), performances.last.showing_on
    assert_requested :get, WHATS_ON, times: 1
  end

  def test_at_keeps_to_the_range
    assert_equal 2, at(from: Date.new(2026, 11, 4), to: Date.new(2026, 11, 4)).count
  end

  def test_at_defaults_to_two_weeks_from_today
    performances = PrincecharlesUk::Performance.stub(:today, FIXTURE_DAY) { PrincecharlesUk::Performance.at('PRILON') }

    assert_equal 16, performances.count
    assert_operator performances.last.showing_on, :<=, FIXTURE_DAY + 13
  end

  def test_at_sets_cinema_details
    performances = performances_at('PRILON')

    assert_equal ['PRILON'], performances.map(&:cinema_id).uniq
    assert_equal ['Prince Charles Cinema'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('PRILON').first

    assert_equal 'Perfect Blue', performance.film_name
    assert_equal 1997, performance.film_year
    assert_equal Time.utc(2026, 11, 1, 18, 5), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(subtitled), performance.variant
    assert_nil performance.festival
    assert_nil performance.booking_url
  end

  def test_booking_urls
    assert_equal "#{BOOKING}31628216/", find('Your Name').booking_url
  end

  def test_years_in_titles_come_first
    assert_equal 1954, find('Godzilla').film_year
    assert_equal 1975, find('Night Moves').film_year
  end

  def test_placeholder_and_missing_years_are_nil
    assert_nil find('Mystery Movie').film_year
    assert_nil find('A Tale of Winter').film_year
  end

  def test_film_gauges
    assert_equal %w(35mm), find('Short Cuts').variant
    assert_equal %w(70mm), find('2001: A Space Odyssey').variant
  end

  def test_q_and_a
    assert_equal %w(q&a), find('Dead Souls').variant
  end

  def test_live_scores_are_arts
    assert_equal %w(arts), find('The Adventures of Prince Achmed').variant
  end

  def test_hard_of_hearing_screenings_are_subtitled
    assert_equal %w(subtitled), find("It's A Wonderful Life").variant
  end

  def test_sing_alongs_from_tags_and_titles
    tagged = find('The Rocky Horror Picture Show')
    titled = find('Rocky Horror Picture Show')

    assert_equal %w(sing_along), tagged.variant
    assert_equal %w(sing_along), titled.variant
    assert_nil titled.booking_url
  end

  def test_offers_and_introductions_are_not_variants
    assert_empty find('The Last Temptation of Christ').variant
    assert_empty find('The Long Day Closes').variant
  end

  def test_three_d_from_titles
    stub_request(:get, WHATS_ON).to_return(status: 200, body: whats_on_html.sub('>Mystery Movie<', '>Mystery Movie 3D<'))

    assert_equal '3d', find('Mystery Movie').dimension
  end

  def test_unknown_cinema_makes_no_request
    assert_empty PrincecharlesUk::Performance.at('ZZZ', from: FIXTURE_DAY, to: FIXTURE_DAY)
    assert_not_requested :get, WHATS_ON
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { at(from: FIXTURE_DAY, to: FIXTURE_DAY - 1) }
  end

  private

  def performances_at(cinema_id)
    PrincecharlesUk::Performance.at(cinema_id, from: FIXTURE_DAY, to: FIXTURE_DAY + 365)
  end

  def at(from:, to:)
    PrincecharlesUk::Performance.at('PRILON', from: from, to: to)
  end

  def find(film_name)
    performances_at('PRILON').detect { |p| p.film_name == film_name }
  end
end
