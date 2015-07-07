class DoorEntryMailer < ActionMailer::Base
  include CmsConfigHelper
  helper CmsConfigHelper
  
  def admin_notification_email(user)
    @user = user

    mail(from: config_or_locale(:company_admin_email_from), to: ENV['COMPANY_ADMIN_EMAIL'], subject: "Door entry at #{config_or_locale(:company_name)}")
  end
end
