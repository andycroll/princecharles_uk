# The parts of the what's on page the gem reads. Checked against the trimmed
# fixture and, in the live suite, against the real page held only in memory.
module ApiShapes
  BOOKING_URL = %r{\Ahttps://princecharlescinema\.com/prince-charles-cinema/booknow/\d+/\z}
  TAG = /\A[a-z0-9-]+\z/
  FILM = PrincecharlesUk::Internal::Parser::WhatsOn::FILM
  HEADING = %r{<div class="heading">([^<]+)</div>}

  private

  def assert_whats_on_shape(html, today:)
    films = html.split(FILM).drop(1)
    refute_empty films
    films.each { |film| assert_match PrincecharlesUk::Internal::Parser::WhatsOn::TITLE, film }
    assert_headings_shape(html)
    showings = PrincecharlesUk::Internal::Parser::WhatsOn.new(html, today: today).showings
    assert_equal html.scan(/<span class="time">/).size, showings.size
    showings.each { |showing| assert_showing_shape(showing, today) }
  end

  def assert_headings_shape(html)
    headings = html.scan(HEADING).flatten.map(&:strip)
    refute_empty headings
    headings.each { |heading| assert_match PrincecharlesUk::Internal::Parser::WhatsOn::HEADING, heading }
  end

  def assert_showing_shape(showing, today)
    refute_empty showing.title
    assert_operator showing.date, :>=, today - 1
    assert_kind_of Time, showing.starting_at
    showing.tags.each { |tag| assert_match TAG, tag }
    assert(showing.booking_url.nil? || showing.booking_url.match?(BOOKING_URL), showing.booking_url)
  end
end
