class DoorEntryMailer < ActionMailer::Base
  include CmsConfigHelper
  helper CmsConfigHelper
  
  def admin_notification_email(user, mesg = '')
    @user = user
    @mesg = mesg
    
    mail(from: config_or_locale(:company_admin_email_from), to: config_or_locale(:company_admin_email_from),
         subject: "Door entry at #{config_or_locale(:company_name)}")
  end
end
