require 'test_helper'

class ProfileUpdateBehaviorTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  def setup
    Capybara.default_driver = :selenium
    visit dash_path(link_secret: users(:user_only_number).secret_link.secret)
  end

  test "email and name update boxes are shown" do
    assert has_css?('#email_address')
    assert has_css?('#username')
  end

  test 'form filling works' do
    describe "Bad data is rejected" do
    end

    describe 'Good data is accepted' do
      it 'allows email and name to be input' do
        fill_in '#email_address', with: 'email@email.com'
        find('input#profile-update-form-submit').click
        e = find('#username')
        assert_not has_css?('#email_address', visible: true)

        fill_in '#username', with: 'first last'
        find('input#profile-update-form-submit').click
        e = find('#opendoor')
        assert_not has_css?('#username', visible: true)        
      end
    end
  end

  def teardown
    Capybara.default_driver = :rack_test
  end
end
