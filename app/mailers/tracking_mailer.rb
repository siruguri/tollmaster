class TrackingMailer < ActionMailer::Base
  include CmsConfigHelper
  helper CmsConfigHelper
    
  def tracking_email(mesg)
    # Send tracking emails for the door app
    mail(from: config_or_locale(:company_admin_email_from),
         subject: "Door App tracker message",
         body: mesg,
         to: config_or_locale(:tracking_email_to))
  end
end
