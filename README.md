# PrincecharlesUk

A simple gem to pull the cinema and its performances from the [Prince Charles Cinema website](https://princecharlescinema.com) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'princecharles_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install princecharles_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

No token or setup is needed. The website runs on WordPress with Jacro's
cinema plugin, and tickets are sold through Jacro's TapOS. Its what's on page
lists every film on sale with every advertised showtime, months ahead, so one
request reads the whole programme.

### Cinema

The Prince Charles Cinema has one venue, keyed by its Jacro site code,
`PRILON`. The gem holds its details: the address from the website's location
page and coordinates from OpenStreetMap. Cinema methods make no requests.

``` ruby
PrincecharlesUk::Cinema.all
#=> [<PrincecharlesUk::Cinema ...>]

cinema = PrincecharlesUk::Cinema.new('PRILON')
#=> <PrincecharlesUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '7 Leicester Place',
  extended_address: nil,
  locality:         'London',
  region:           nil,
  postal_code:      'WC2H 7BY',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Prince Charles Cinema'

cinema.id
#=> 'PRILON'

cinema.latitude
#=> 51.5114907

cinema.url
#=> 'https://princecharlescinema.com'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. Any range is one
request.

``` ruby
PrincecharlesUk::Performance.at('PRILON', from: Date.today, to: Date.today + 365)
#=> [<PrincecharlesUk::Performance ...>, <PrincecharlesUk::Performance ...>, ...]

performance = PrincecharlesUk::Performance.at('PRILON', from: Date.today, to: Date.today + 365).last
#=> <PrincecharlesUk::Performance ...>

performance.film_name
#=> 'The Rocky Horror Picture Show' # from '... : Sing Along'

performance.film_year
#=> 1975

performance.dimension
#=> '2d'

performance.variant
#=> ['sing_along']

performance.subtitled?
#=> false

performance.festival
#=> nil

performance.starting_at
#=> 2027-06-25 19:30:00 UTC

performance.booking_url
#=> 'https://princecharlescinema.com/prince-charles-cinema/booknow/31628659/'

performance.cinema_name
#=> 'Prince Charles Cinema'

performance.cinema_id
#=> 'PRILON'
```

Booking links are the website's own booking pages, which hold the TapOS seat
selection. Sold out screenings are listed with no booking link.

Date headings such as 'Friday 25th June' give no year. The gem takes the year
in which that date falls on that weekday.

Variants come from each showtime's tags and from titles: `35mm`, `70mm`,
`subtitled` (SUB and HOH, hard of hearing, screenings), `q&a`, `sing_along`
and `arts` (films with a live score). 4K, £1 member tickets, introductions,
previews and final shows are not variants.

Film years come from a year in the title, such as 'Godzilla (1954)' or
'The Mummy [1999]', or else from the listing. Placeholder years before 1888,
which the listing gives to some events such as 'Mystery Movie', are dropped.

Titles are cleaned up:

- Original titles, cuts and notes in square brackets go: 'Rashomon [Rashômon]'
  becomes 'Rashomon', 'The New World [Extended Cut]' becomes 'The New World'.
- A final parenthesis goes: 'Daisies (Sedmikrásky)' becomes 'Daisies', and
  'Ten Years of Monkey Tennis (with Peter Serafinowicz)' loses its guest.
- Anniversaries, restorations and touring prints go: 'Amelie - 25th
  Anniversary', 'Wake in Fright - 4K Restoration', 'Short Cuts : 35mm Roadshow
  Tour'.
- Sing-along names go: 'The Rocky Horror Picture Show: Sing Along' and
  'Sing-A-Long-A Rocky Horror Picture Show'.
- Q&A add-ons go: 'Dead Souls + Alex Cox Q&A' becomes 'Dead Souls'.
- Presenters go: 'Funeral Parade presents "The Long Day Closes"' becomes 'The
  Long Day Closes'.
- Spaced colons close up: '2001 : A Space Odyssey' becomes '2001: A Space
  Odyssey'.

Director's and final cuts named after a colon keep their names. Double bills,
marathons and all-nighters keep the cinema's names, such as 'Studio Ghibli
All-Nighter' and 'Evangelion: Death (True)² + The End of Evangelion: Double
Feature'.

## Tests

```sh
bundle exec rake                # unit tests against fixtures
LIVE=1 bundle exec rake live    # live princecharlescinema.com
```

The fixture in `test/fixtures` is the what's on page, trimmed to a few films
with shortened descriptions and no posters. `test/support/api_shapes.rb`
describes the markup the gem reads. The unit suite checks the fixture against
it and the live suite checks the real page, held only in memory. When the page
changes, update the shape first, then the fixture.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
