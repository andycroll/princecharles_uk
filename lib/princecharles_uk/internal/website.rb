# frozen_string_literal: true

module PrincecharlesUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads the Prince Charles Cinema's WordPress website, built on Jacro's
    # cinema plugin. No token is needed.
    class Website
      include Http

      WHATS_ON = 'https://princecharlescinema.com/whats-on/'

      # @return [String] every film on sale with every advertised showtime,
      #   however far ahead, including sold out ones
      def whats_on
        get(WHATS_ON)
      end
    end
  end
end
