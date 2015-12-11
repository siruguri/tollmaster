require 'test_helper'

class FreshUserDashboardTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  self.use_transactional_fixtures = false
  before do
    Capybara.default_driver = :selenium

    @secret = 'has_secret_not_active_secret'
    v = SecretLink.find_by_encrypted_secret(@secret).user
    visit dash_path(link_secret: @secret)
  end

  describe 'Good data is accepted' do
    it 'works' do
      valid_name
      valid_credit_card
      find('#form-submit').click

      page.find('#linksecret', visible: false)
      assert_match /\/dash\/.+/, page.current_path
      assert_match /information valid/, page.body
      
      v = SecretLink.find_by_encrypted_secret(@secret).user
      assert_equal test_email, v.email
    end
  end

  describe "CC screen is shown" do
    it "works" do
      assert page.has_css?('#cc_number')
    end
  end
  
  after do
    Capybara.default_driver = :rack_test
  end

  private
  def valid_name
    profile_fields.each do |pair|
      page.fill_in "#{pair[0]}", with: pair[1]
    end
  end
    
  def valid_credit_card
    fields.each do |pair|
      page.fill_in "#{pair[0]}", with: pair[1]
    end 
  end

  def invalid_credit_card
    bad_fields.each do |pair|
      page.fill_in "#{pair[0]}", with: pair[1]
    end 
  end

  def test_email
    'email@ermail.com'
  end
  
  def profile_fields
    [['email_address', test_email], ['username', 'user name']]
  end

  def fields
    [['cc_number', '5555555555554444'], ['cvc', '123'], ['exp_month', '10'], ['exp_year', '25']]
  end

  def bad_fields
    [['cc_number', '1555555555555444'], ['cvc', '123'], ['exp_month', '10'], ['exp_year', '25']]
  end

  def assert_incorrect_input(id, inp_text)
    old_value = page.find("input##{id}").value()
    page.fill_in "#{id}", with: inp_text
    page.find("#form-submit").click
    page.find('#payment-errors')
    
    assert_match /missing.*incorrect/i, page.body
    page.fill_in "#{id}", with: old_value
  end
end
