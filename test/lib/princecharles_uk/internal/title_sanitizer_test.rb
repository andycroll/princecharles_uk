require_relative '../../../test_helper'

class PrincecharlesUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Perfect Blue', 'Perfect Blue'
    assert_sanitized "Ken Russell's The Devils: The Director's Cut", "Ken Russell's The Devils: The Director's Cut"
  end

  def test_original_titles_cuts_and_years_in_square_brackets
    assert_sanitized 'Your Name', 'Your Name [Kimi no Na wa.]'
    assert_sanitized 'Rashomon', 'Rashomon [Rashômon]'
    assert_sanitized 'The New World', 'The New World [Extended Cut]'
    assert_sanitized 'Die Hard', 'Die Hard [is a Christmas Movie]'
    assert_sanitized 'Night Moves', 'Night Moves [1975]'
  end

  def test_trailing_parentheses
    assert_sanitized 'Godzilla', 'Godzilla (1954)'
    assert_sanitized 'Daisies', 'Daisies (Sedmikrásky)'
    assert_sanitized 'Ten Years of Monkey Tennis', 'Ten Years of Monkey Tennis (with Peter Serafinowicz)'
  end

  def test_anniversaries_and_restorations
    assert_sanitized 'Amelie', 'Amelie - 25th Anniversary'
    assert_sanitized 'Labyrinth', 'Labyrinth - 40th Anniversary'
    assert_sanitized 'Wake in Fright', 'Wake in Fright - 4K Restoration'
  end

  def test_film_formats
    assert_sanitized 'Short Cuts', 'Short Cuts : 35mm Roadshow Tour'
  end

  def test_sing_alongs
    assert_sanitized 'The Rocky Horror Picture Show', 'The Rocky Horror Picture Show: Sing Along'
    assert_sanitized 'Rocky Horror Picture Show', 'Sing-A-Long-A Rocky Horror Picture Show'
  end

  def test_q_and_a
    assert_sanitized 'Dead Souls', 'Dead Souls + Alex Cox Q&A'
  end

  def test_presenters
    assert_sanitized 'The Long Day Closes', 'Funeral Parade presents "The Long Day Closes"'
    assert_sanitized 'Welcome To Hell & Bag of Suck Double Feature',
                     'Have A Gd Trip presents Welcome To Hell & Bag of Suck Double Feature'
  end

  def test_spaced_colons
    assert_sanitized '2001: A Space Odyssey', '2001 : A Space Odyssey'
    assert_sanitized 'Evangelion: Death (True)² + The End of Evangelion: Double Feature',
                     'Evangelion: Death (True)² + The End of Evangelion : Double Feature'
  end

  def test_marathons_keep_their_names
    assert_sanitized 'Studio Ghibli All-Nighter', 'Studio Ghibli All-Nighter'
    assert_sanitized 'The Lord of the Rings Trilogy', 'The Lord of the Rings Trilogy [Theatrical Editions]'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, PrincecharlesUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
