require 'test_helper'

class RailsAdminSigninTest < Capybara::Rails::TestCase
  test 'admin signin required' do
    visit '/rails_admin'
    assert_equal '/admins/sign_in', page.current_path

    admin = admins(:admin_1)
    fill_in 'admin[email]', with: admin.email
    fill_in 'admin[password]', with: 'password'
    
    page.click_button 'Login'
    visit '/rails_admin'
    assert_equal '/rails_admin', page.current_path
  end
end
