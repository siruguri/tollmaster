require 'test_helper'

class DashboardBehaviorTest < Capybara::Rails::TestCase
  include Rack::Test::Methods
  self.use_transactional_fixtures = false

  before do
    Capybara.default_driver = :selenium
  end

  describe "Checked in user" do
    before do
      @user = users(:user_with_paid_session)
      visit dash_path(link_secret: @user.secret_link.secret)
      ActionMailer::Base.deliveries.clear
    end
    
    it "can open door" do
      click_button 'Open Door'
      assert_not ActionMailer::Base.deliveries.empty?
      assert_match /door opened/i, page.body
    end

    it "can check out" do
      click_button 'Check out'
      assert_match /check in/i, page.body

      assert_not @user.has_active_session?
    end
  end
end

