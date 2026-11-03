module PrincecharlesUk
  # A single screening of a film on the Prince Charles Cinema website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String, nil] the booking URL, nil when sold out
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year of the film
    #   @option options [Time] :starting_at listed start time of the performance
    #   @option options [String] :title (nil) raw title, for audience variants

    # Showtime tags and the variants they mean. HOH (hard of hearing)
    # screenings are subtitled. Others, such as '4k', '1-mem' (£1 member
    # tickets), 'intro', 'preview' and 'final-show', are not variants.
    TAGS = {
      '35mm' => '35mm',
      '70mm' => '70mm',
      'hoh' => 'subtitled',
      'live-score' => 'arts',
      'q-a' => 'q&a',
      'sing-along' => 'sing_along',
      'sub' => 'subtitled'
    }.freeze

    # Variants some titles name without a tag
    TITLE_VARIANTS = {
      /\b35mm\b/i => '35mm',
      /\b70mm\b/i => '70mm',
      /\bQ&A\b/i => 'q&a',
      /\bSing[- ]?A[- ]?Long\b/i => 'sing_along'
    }.freeze

    THREE_D = /\b3D\b/i
    # Bracketed years in titles, such as 'The Mummy [1999]'
    TITLE_YEAR = /[(\[](1[89]\d{2}|20\d{2})[)\]]\s*\z/
    # Listings give placeholder years to some events, e.g. 1878
    FIRST_FILM_YEAR = 1888

    # Performances within an inclusive range of showing dates, from one
    # request: the what's on page holds every advertised date.
    # @param [String] cinema_id the cinema's Jacro site code, 'PRILON'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<PrincecharlesUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      if cinema.name.empty?
        []
      else
        performances = showings.select { |showing| (from..to).cover?(showing.date) }.map do |showing|
          new(attributes(showing).merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
        performances.sort_by(&:starting_at)
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (35mm, 70mm, q&a, sing_along, subtitled ...)
    #   @return <Array[String]>

    def self.showings
      html = PrincecharlesUk::Internal::Website.new.whats_on
      PrincecharlesUk::Internal::Parser::WhatsOn.new(html, today: Cinebase::London.today).showings
    end
    private_class_method :showings

    def self.attributes(showing)
      title = showing.title
      {
        booking_url: showing.booking_url,
        dimension: [title, *showing.tags].any? { |text| text.match?(THREE_D) } ? '3d' : '2d',
        festival: Cinebase::Festival.from_title(title, year: showing.date.year),
        film_name: PrincecharlesUk::Internal::TitleSanitizer.new(title).sanitized,
        film_year: film_year(showing),
        starting_at: showing.starting_at,
        title: title,
        variant: variant(showing)
      }
    end
    private_class_method :attributes

    # A year in the title first, as it picks out one version of a film
    def self.film_year(showing)
      year = showing.title[TITLE_YEAR, 1]&.to_i || showing.year
      year if year && year >= FIRST_FILM_YEAR
    end
    private_class_method :film_year

    def self.variant(showing)
      from_tags = showing.tags.filter_map { |tag| TAGS[tag] }
      from_title = TITLE_VARIANTS.filter_map { |pattern, variant| variant if showing.title.match?(pattern) }
      (from_tags + from_title).uniq
    end
    private_class_method :variant
  end
end
