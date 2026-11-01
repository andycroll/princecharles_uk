# Read fixtures from disk: the what's on page from 1 November 2026, trimmed
# to a few films with shortened descriptions and no posters. It follows the
# shape in api_shapes.rb.
module FixturesHelper
  FIXTURE_DAY = Date.new(2026, 11, 1)

  private

  def whats_on_html
    read_fixture('website/whats-on.html')
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
