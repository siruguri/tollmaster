require 'test_helper'

class PrepareInvoicesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test 'Can prepare invoices for all users in one go' do
    initial_invoice_count = Invoice.count
    PrepareInvoicesJob.perform_now(:all)
    assert_equal initial_invoice_count + 2, Invoice.count
    assert [users(:user_with_completed_sessions).id, users(:user_with_completed_sessions_2).id].include?(Invoice.last.payer_id)
  end

  test 'Can prepare invoices for one specific user' do
    u = users(:user_with_completed_sessions_2)

    initial_invoice_count = Invoice.count
    PrepareInvoicesJob.perform_now u

    # This cannot possible be the best way to test this, given its deep knowledge of how
    # GlobalID works. :(
    assert_equal u.email, GlobalID::Locator.locate(enqueued_jobs[0][:args][3]['_aj_globalid']).email
    assert_equal initial_invoice_count + 1, Invoice.count
    assert_equal users(:user_with_completed_sessions_2), Invoice.last.payer
  end

  test 'invoicing uses minimum and maximum cost' do
    u = users(:user_with_completed_sessions)
    PrepareInvoicesJob.perform_now u

    i = Invoice.where(payer: u).first

    assert_equal 576500, i.amount
  end
end
