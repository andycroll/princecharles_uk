# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2026-11-03

### Changed
- Uses cinebase 5.9: performances take the raw `title:`, so audience labels become variants, and series prefixes such as `Met Opera:` become the performance's `event`.

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- HTTP errors read "HTTP error 500 from princecharlescinema.com" instead of "Prince Charles Cinema HTTP error 500".

### Removed
- `PrincecharlesUk::Performance::TIME_ZONE`, now unused.

## [1.0.0] - 2026-11-01

The first release, as 1.0.0.

### Added
- `PrincecharlesUk::Cinema.all` and `PrincecharlesUk::Cinema.new(id)` for the Prince Charles Cinema, keyed by its Jacro site code, `PRILON`, with its address from the website's location page and coordinates from OpenStreetMap.
- `PrincecharlesUk::Performance.at(id, from:, to:)`, from the what's on page of the cinema's WordPress website, built on Jacro's cinema plugin with TapOS ticketing, which holds every advertised date in one request. Sold out screenings are included without a booking link.
- Variants from showtime tags and titles, including `sing_along`, film years from titles or the listing, and title clean-up for original titles, anniversaries, presenters and sing-alongs.
- Fixtures trimmed from a live page, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
