require 'test_helper'

class DashboardBehaviorTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper
  self.use_transactional_fixtures = false

  before do
    Capybara.default_driver = :selenium
    set_net_stubs
  end

  describe "Checked in user" do
    before do
      @user = users(:user_with_paid_session)
      visit dash_path(link_secret: 'user_with_paid_session_secret')
    end
    
    it "can open door" do
      click_button 'Open door'
      assert_match /should be open/i, page.body
      assert_enqueued_jobs 1
    end

    it "can check out" do
      click_button 'Check out'
      assert_match /check in and open/i, page.body

      assert_not @user.has_active_session?
    end
  end
end

