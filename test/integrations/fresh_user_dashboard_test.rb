require 'test_helper'

class FreshUserDashboardTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  def setup
    set_net_stubs
    Capybara.default_driver = :selenium
    visit dash_path(link_secret: 'has_secret_not_active_secret')
  end

  test "CC screen is shown" do
    assert has_css?('#cc_number')
  end

  test 'form filling works' do
    describe "Bad data is rejected" do
      it "Performs numeric validations" do
        valid_name
        valid_credit_card

        ['username', 'email_address'].each do |id|
          assert_incorrect_input(id, '')
        end          
        
        ['cc_number', 'cvc', 'exp_month', 'exp_year'].each do |id|
          assert_incorrect_input(id, 'aa')
        end
      end

      it 'shows stripe_error messages' do
        invalid_credit_card
        find('input#form-submit').click
        find('#primary-key')
        
        assert_operator page.find('#payment-errors').text.strip.size, :>, 0
      end
    end

    describe 'Good data is accepted' do
      it 'asks for cc for new user' do
        valid_credit_card
        find('input#form-submit').click

        assert_match /\/dash\/.+/, page.current_path
        e = find('#opendoor')
        assert_nil e[:disabled]
      end
    end
  end

  def teardown
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

  def profile_fields
    [['email_address', 'email@ermail.com'], ['username', 'user name']]
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
    page.find("input#form-submit").click

    assert page.has_content?('inputs is incorrect')
    page.fill_in "#{id}", with: old_value
  end
end
