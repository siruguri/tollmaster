require 'test_helper'

class InvoiceMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper
  
  test 'mail format' do
    u = users(:user_with_completed_sessions)
    email = nil

    perform_enqueued_jobs do 
      PrepareInvoicesJob.perform_now(u) #InvoiceMailer.invoice_email(u)
    end
    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last

    assert_match /nomadawhat/i, email.from[0]

    assert_match /nomad.a.what/i, email.body.raw_source
    assert_match /915\s+seconds/, email.body.raw_source
    assert_match /\$2265\.00/, email.body.raw_source
  end
end
