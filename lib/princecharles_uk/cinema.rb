module PrincecharlesUk
  # The object representing the Prince Charles Cinema, London
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's Jacro site code, 'PRILON'

    # The cinema has one venue. Its Jacro site code names it in ticketing
    # links. The address is from the website's location page, coordinates
    # from OpenStreetMap.
    VENUES = {
      'PRILON' => {
        name: 'Prince Charles Cinema', street_address: '7 Leicester Place', locality: 'London',
        postal_code: 'WC2H 7BY', latitude: 51.5114907, longitude: -0.1302137
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    URL = 'https://princecharlescinema.com'.freeze

    # Constructor
    # @param [String] id the cinema's Jacro site code, 'PRILON' or 'prilon'
    # @return [PrincecharlesUk::Cinema]
    def initialize(id)
      @id = id.to_s.upcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<PrincecharlesUk::Cinema>] the one cinema
    # @example
    #   PrincecharlesUk::Cinema.all
    #   #=> [<PrincecharlesUk::Cinema>]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = PrincecharlesUk::Cinema.new('PRILON')
    #   cinema.adr
    #   #=> {
    #         street_address:   '7 Leicester Place',
    #         extended_address: nil,
    #         locality:         'London',
    #         region:           nil,
    #         postal_code:      'WC2H 7BY',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   PrincecharlesUk::Cinema.new('PRILON').name
    #   #=> 'Prince Charles Cinema'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's website
    # @return [String]
    # @example
    #   PrincecharlesUk::Cinema.new('PRILON').url
    #   #=> 'https://princecharlescinema.com'
    def url
      venue.empty? ? '' : URL
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
