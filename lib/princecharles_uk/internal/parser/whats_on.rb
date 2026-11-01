# frozen_string_literal: true

module PrincecharlesUk
  # @api private
  module Internal
    module Parser
      # One showtime from the what's on page
      Showing = Data.define(:title, :year, :date, :starting_at, :tags, :booking_url)

      # Parses the what's on page: one block per film, each with its
      # showtimes under date headings such as 'Friday 25th June'
      class WhatsOn
        FILM = /<div class="jacro-event movie-tabs row/
        TITLE = /class="liveeventtitle"[^>]*>([^<]+)</
        # The first detail is the film's year when the listing gives one
        DETAILS = %r{<div class="running-time">\s*<span>([^<]*)</span>}
        YEAR = /\A\d{4}\z/
        SHOWTIMES = %r{<ul class="performance-list-items">(.*?)</ul>}m
        HEADING_OR_SHOWTIME = %r{<div class="heading">([^<]+)</div>|<li class="([^"]*)">(.*?)</li>}m
        HEADING = /\A(\w+) (\d{1,2})(?:st|nd|rd|th) (\w+)\z/
        TIME = %r{<span class="time">\s*(\d{1,2}):(\d{2})\s*([ap]m)\s*</span>}i
        # Sold out showtimes have no link
        BOOKING = %r{href="(https://princecharlescinema\.com/[\w-]+/booknow/\d+)/?"}
        TIME_ZONE = 'Europe/London'
        HOURS_TO_NOON = 12

        # @param [String] html the what's on page
        # @param [Date] today in London, to place headings, which give no
        #   year, in the right year
        def initialize(html, today:)
          @html = html
          @today = today
        end

        # @return [Array<PrincecharlesUk::Internal::Parser::Showing>]
        def showings
          @html.split(FILM).drop(1).flat_map { |film| film_showings(film) }
        end

        private

        def film_showings(film)
          title = CGI.unescapeHTML(film[TITLE, 1].to_s).strip
          year = film[DETAILS, 1].to_s.strip
          year = year.match?(YEAR) ? year.to_i : nil
          date = nil
          film[SHOWTIMES, 1].to_s.scan(HEADING_OR_SHOWTIME).filter_map do |heading, tags, showtime|
            if heading
              date = date(heading.strip)
              nil
            elsif date && showtime.match?(TIME)
              showing(title, year, date, tags, showtime)
            end
          end
        end

        def showing(title, year, date, tags, showtime)
          Showing.new(
            title: title,
            year: year,
            date: date,
            starting_at: starting_at(date, showtime),
            tags: tags.split,
            booking_url: booking_url(showtime)
          )
        end

        def booking_url(showtime)
          url = showtime[BOOKING, 1]
          url ? "#{url}/" : nil
        end

        # The year whose date falls on the heading's weekday, or failing
        # that the first on or after today
        def date(heading)
          weekday, day, name = heading.match(HEADING)&.captures
          month = name && Date::MONTHNAMES.index(name)
          if month
            dates = (@today.year - 1..@today.year + 1).filter_map do |year|
              Date.new(year, month, day.to_i) if Date.valid_date?(year, month, day.to_i)
            end
            dates.find { |date| Date::DAYNAMES[date.wday] == weekday } || dates.find { |date| date >= @today }
          end
        end

        def starting_at(date, showtime)
          hour, minute, meridiem = showtime.match(TIME).captures
          hour = hour.to_i % HOURS_TO_NOON
          hour += HOURS_TO_NOON if meridiem.casecmp?('pm')
          local = Time.utc(date.year, date.month, date.day, hour, minute.to_i)
          TZInfo::Timezone.get(TIME_ZONE).local_to_utc(local) { |periods| periods.first }.utc
        end
      end
    end
  end
end
