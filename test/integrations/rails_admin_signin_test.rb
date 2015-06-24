require 'test_helper'

class RailsAdminSigninTest < Capybara::Rails::TestCase
  test 'signin required' do
    visit '/rails_admin'
    assert_equal '/users/sign_in', page.current_path
  end
end
