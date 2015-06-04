require 'test_helper'

class PrepareInvoicesJobTest < ActiveSupport::TestCase

  def setup
  end
  
  test 'job works' do
    PrepareInvoicesJob.perform_now
    assert_equal 2, Invoice.count
    assert [users(:user_with_completed_sessions).id, users(:user_with_completed_sessions_2).id].include?(Invoice.first.user_id)
  end
end
