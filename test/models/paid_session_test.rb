require 'test_helper'

class PaidSessionTest < ActiveSupport::TestCase
  test '#duration' do 
    assert 3705, paid_sessions(:complete_session_1).duration
    assert 3705000, paid_sessions(:complete_session_1).duration(unit: :not_a_unit)
  end
end
