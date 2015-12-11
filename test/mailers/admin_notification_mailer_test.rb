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
    assert_equal CmsConfig.find_by_source_symbol(:company_admin_email_from).target_text, email.to[0]
  end
end
