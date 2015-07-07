class DoorEntryMailer < ActionMailer::Base
  def admin_notification_email(user)
    @user = user
    mail(from: "connect@nomadawhat.com", to: ENV['COMPANY_ADMIN_EMAIL'], subject: "Door entry at Nomad-a-What}")
  end
end
