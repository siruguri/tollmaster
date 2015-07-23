require 'test_helper'

class PhoneNumberManagerTest < ActiveSupport::TestCase
  include PhoneNumberManager
  test 'canonicalization' do
    number = '4077256771'
    can_hash = canonicalize_number('0' + number)

    assert_equal number, can_hash[:number]
    assert_equal false, can_hash[:is_international]
  end

  test 'international canonicalization' do
    number = '4077256771'
    can_hash = canonicalize_number('+0' + number)

    assert_equal number, can_hash[:number]
    assert can_hash[:is_international]
  end
end
