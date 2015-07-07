require 'test_helper'

class AdminNotificationMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper
  
  test 'mail format' do
    u = users(:user_with_completed_sessions)
    email = nil
    DoorEntryMailer.admin_notification_email(u).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last

    assert_equal ['connect@nomadawhat.com'], email.from
    assert_equal 'siruguri@gmail.com', email.to[0]
  end
end
