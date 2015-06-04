require 'test_helper'

class UserEntryFormValidationsTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  before do
    Capybara.default_driver = :selenium
    visit root_path
  end

  describe "First step" do
    it "doesn't allow no phone number" do
      page.find('#pk-submit').click
      assert page.has_content?('enter a phone')
    end
  end

  describe "Second steps: unknown user" do
    before do
      page.fill_in 'primary-key', with: '9999999999'
      page.find('#pk-submit').click

      page.assert_selector '#cc_number'
      page.assert_selector '#payments-form input[name=primary_key]', visible: false
    end
    
    it "Performs numeric validations" do
      ['cc_number', 'cvc'].each do |id|
        page.fill_in "#{id}", with: '1234'
      end
      ['exp_month', 'exp_year'].each do |id|
        page.fill_in "#{id}", with: '12'
      end

      ['cc_number', 'cvc', 'exp_month', 'exp_year'].each do |id|
        old_value = page.find("input##{id}").value()
        page.fill_in "#{id}", with: 'aa'
        page.find("input#form-submit").click

        assert page.has_content?('inputs is incorrect')
        page.fill_in "#{id}", with: old_value
      end
    end

    describe "second step: known user" do
    end
  end

  after do
    Capybara.default_driver = :rack_test
  end
end
