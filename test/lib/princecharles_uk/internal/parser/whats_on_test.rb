require_relative '../../../../test_helper'

class PrincecharlesUk::Internal::Parser::WhatsOnTest < Minitest::Test
  include FixturesHelper

  BOOKING = 'https://princecharlescinema.com/prince-charles-cinema/booknow/'.freeze

  def test_showings_reads_every_showtime
    assert_equal 87, showings.count
    assert_equal 17, showings.map(&:title).uniq.count
  end

  def test_first_showing
    showing = showings.first

    assert_equal 'Perfect Blue', showing.title
    assert_equal 1997, showing.year
    assert_equal Date.new(2026, 11, 1), showing.date
    assert_equal Time.utc(2026, 11, 1, 18, 5), showing.starting_at
    assert_equal %w(sub), showing.tags
  end

  def test_sold_out_showings_have_no_booking_url
    assert_nil showings.first.booking_url
  end

  def test_booking_urls_skip_the_redirect
    assert_equal "#{BOOKING}31628216/", showings[1].booking_url
  end

  def test_titles_are_unescaped
    assert_includes showings.map(&:title), "It's A Wonderful Life"
  end

  def test_listings_without_a_year
    assert_nil showings.detect { |showing| showing.title == 'A Tale of Winter' }.year
  end

  def test_distant_dates_fall_in_next_year_in_summer_time
    showing = showings.last

    assert_equal 'The Rocky Horror Picture Show: Sing Along', showing.title
    assert_equal Date.new(2027, 6, 25), showing.date
    assert_equal Time.utc(2027, 6, 25, 19, 30), showing.starting_at
    assert_equal %w(sing-along), showing.tags
  end

  def test_dates_on_a_page_from_the_new_year_can_be_last_year
    showing = parse(film(heading: 'Thursday 31st December'), today: Date.new(2027, 1, 1)).first

    assert_equal Date.new(2026, 12, 31), showing.date
  end

  def test_a_wrong_weekday_falls_back_to_the_next_such_date
    showing = parse(film(heading: 'Tuesday 1st November'), today: Date.new(2026, 11, 1)).first

    assert_equal Date.new(2026, 11, 1), showing.date
  end

  def test_noon_and_midnight
    showing = parse(film(time: '12:15 pm')).first

    assert_equal Time.utc(2026, 11, 1, 12, 15), showing.starting_at
    assert_equal Time.utc(2026, 11, 1, 0, 15), parse(film(time: '12:15 am')).first.starting_at
  end

  def test_showtimes_under_unreadable_headings_are_skipped
    assert_empty parse(film(heading: 'Sunday 1st Novembre'))
    assert_empty parse(film(heading: 'Tomorrow'))
  end

  def test_items_without_a_time_are_skipped
    assert_empty parse(film(time: 'TBC'))
  end

  def test_a_page_without_films
    assert_empty parse('<html><body>Nothing on</body></html>')
  end

  private

  def showings
    @showings ||= parse(whats_on_html)
  end

  def parse(html, today: FIXTURE_DAY)
    PrincecharlesUk::Internal::Parser::WhatsOn.new(html, today: today).showings
  end

  def film(heading: 'Sunday 1st November', time: '6:05 pm')
    <<~HTML
      <div class="jacro-event movie-tabs row">
        <a class="liveeventtitle" href="https://princecharlescinema.com/film/1/perfect-blue">Perfect Blue</a>
        <div class="running-time"><span>81mins</span></div>
        <ul class="performance-list-items"><div class="heading">#{heading}</div>
          <li class=""><a href="#{BOOKING}1" class="film_book_button"><span class="time">#{time}</span></a></li>
        </ul>
      </div>
    HTML
  end
end
