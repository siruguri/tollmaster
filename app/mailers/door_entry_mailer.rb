class DoorEntryMailer < ActionMailer::Base
  def admin_notification_email(user)
    @user = user
    mail(from: "admin@rockitcolabs.com", to: ENV['COMPANY_ADMIN_EMAIL'], subject: "Door entry at Rockit")
  end
end
