class DoorEntryMailer < ActionMailer::Base
  default(from: "admin@rockitcolabs.com", to: 'siruguri@gmail.com', subject: "Door entry at Rockit")

  def admin_notification_email(user)
    @user = user
    mail(from: "admin@rockitcolabs.com", to: 'siruguri@gmail.com', subject: "Door entry at Rockit")
  end
end
