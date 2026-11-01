require_relative 'fixtures_helper'

# Serve the fixture in place of the Prince Charles Cinema website
module WebsiteStubs
  include FixturesHelper

  WHATS_ON = 'https://princecharlescinema.com/whats-on/'.freeze

  private

  def stub_whats_on
    stub_request(:get, WHATS_ON).to_return(status: 200, body: whats_on_html)
  end
end
