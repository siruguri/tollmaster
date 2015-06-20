require 'test_helper'

class PrepareInvoicesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test 'Can prepare invoices for all users in one go' do
    PrepareInvoicesJob.perform_now(:all)
    assert_equal 2, Invoice.count
    assert [users(:user_with_completed_sessions).id, users(:user_with_completed_sessions_2).id].include?(Invoice.first.payer_id)
  end

  test 'Can prepare invoices for one specific user' do
    u = users(:user_with_completed_sessions_2)
    PrepareInvoicesJob.perform_now u

    # This cannot possible be the best way to test this, given it's deep knowledge of how
    # GlobalID works. :(
    assert_equal u.email, GlobalID::Locator.locate(enqueued_jobs[0][:args][3]['_aj_globalid']).email
    assert_equal 1, Invoice.count
    assert_equal users(:user_with_completed_sessions_2), Invoice.first.payer
  end
end
