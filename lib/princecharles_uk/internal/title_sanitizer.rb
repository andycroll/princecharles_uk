module PrincecharlesUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [PrincecharlesUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\A.+?\s+presents\s+/i,                        # presenter, e.g. 'Funeral Parade presents'
          /\ASing-A-Long-A\s+/i,                         # sing-along prefix
          /:\s*Sing[- ]?A[- ]?Long\z/i,                  # sing-along suffix
          /\s+-\s+\d+(?:st|nd|rd|th) Anniversary\z/i,    # anniversary re-release
          /\s+-\s+4K Restoration\z/i,                    # restoration
          /\s*:\s*35mm Roadshow Tour\z/i,                # touring print
          /\s*\[[^\]]*\]\z/,                             # original title, cut or year, e.g. '[Rashômon]'
          /\s*\([^)]*\)\z/                               # original title, guest or year, e.g. '(Sedmikrásky)'
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A"(.*)"\z/  => '', # quotes left by a presenter
          /\s+:\s+(.*)/ => ': ' # spaced colon, e.g. '2001 : A Space Odyssey'
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
