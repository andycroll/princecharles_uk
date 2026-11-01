require_relative '../../../test_helper'

class PrincecharlesUk::Internal::WebsiteTest < Minitest::Test
  include WebsiteStubs

  def test_whats_on_reads_the_page
    stub_whats_on

    assert_includes PrincecharlesUk::Internal::Website.new.whats_on, 'Perfect Blue'
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, WHATS_ON).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { PrincecharlesUk::Internal::Website.new.whats_on }
    assert_equal 'Prince Charles Cinema HTTP error 500', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:get, WHATS_ON).to_return(status: 301, headers: { 'Location' => 'https://princecharlescinema.com/' })

    assert_raises(RuntimeError) { PrincecharlesUk::Internal::Website.new.whats_on }
  end

  def test_transient_errors_are_retried
    stub_request(:get, WHATS_ON).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: whats_on_html)
    website = PrincecharlesUk::Internal::Website.new

    website.stub(:sleep, nil) { website.whats_on }

    assert_requested :get, WHATS_ON, times: 2
  end

  def test_transient_errors_are_raised_after_retries
    stub_request(:get, WHATS_ON).to_raise(Net::OpenTimeout)
    website = PrincecharlesUk::Internal::Website.new

    assert_raises(Net::OpenTimeout) { website.stub(:sleep, nil) { website.whats_on } }
    assert_requested :get, WHATS_ON, times: 3
  end
end
