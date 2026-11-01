require_relative '../../test_helper'

class PrincecharlesUk::CinemaTest < Minitest::Test
  def test_all_returns_the_one_cinema_without_requests
    cinemas = PrincecharlesUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(PrincecharlesUk::Cinema) })
    assert_equal %w(PRILON), cinemas.map(&:id)
  end

  def test_new_stores_upcase_string_id
    assert_equal 'PRILON', PrincecharlesUk::Cinema.new('prilon').id
  end

  def test_name_full_name_and_slug
    cinema = PrincecharlesUk::Cinema.new('PRILON')

    assert_equal 'Prince Charles Cinema', cinema.name
    assert_equal 'Independent Prince Charles Cinema', cinema.full_name
    assert_equal 'independent-prince-charles-cinema', cinema.slug
  end

  def test_brand
    assert_equal 'Independent', PrincecharlesUk::Cinema.new('PRILON').brand
  end

  def test_url
    assert_equal 'https://princecharlescinema.com', PrincecharlesUk::Cinema.new('PRILON').url
  end

  def test_adr
    expected = {
      street_address:   '7 Leicester Place',
      extended_address: nil,
      locality:         'London',
      region:           nil,
      postal_code:      'WC2H 7BY',
      country_name:     'United Kingdom'
    }

    assert_equal expected, PrincecharlesUk::Cinema.new('PRILON').adr
  end

  def test_coordinates
    cinema = PrincecharlesUk::Cinema.new('PRILON')

    assert_in_delta 51.5114907, cinema.latitude
    assert_in_delta(-0.1302137, cinema.longitude)
  end

  def test_unknown_cinema_has_no_details
    cinema = PrincecharlesUk::Cinema.new('ZZZ')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
    assert_nil cinema.longitude
  end
end
