require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test 'Validations' do
    assert_not (Payment.new(payment_date: Time.now)).valid?
    assert_not Payment.new(payment_date: Time.now, amount: '123a').valid?

    assert Payment.new(payment_date: Time.now, amount: '123').valid?
  end
end
