require 'test_helper'

class AdminNotificationMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper
  
  test 'mail format' do
    u = users(:user_with_completed_sessions)
    email = nil
    DoorEntryMailer.admin_notification_email(u, 'dummy42').deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last

    assert_match /user with completed sessions/, email.body.raw_source
    assert_match /dummy42/, email.body.raw_source
    assert_equal ['connect@nomadawhat.com'], email.from
    assert_equal Rails.application.secrets.company_admin_email, email.to[0]
  end
end
