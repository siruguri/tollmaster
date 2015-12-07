CmsConfig.all.map &:delete

CmsConfig.find_or_create_by(source_symbol: :company_admin_email_from) do |rec|
  rec.target_text = 'siruguri@gmail.com'
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :tracking_email_to) do |rec|
  rec.target_text = 'sameer@dstrategies.org'
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :footer_tos_text_html) do |rec|
  rec.target_text = "You will be charged $0.10 per minute while checked into our space. Minimum daily charge is $5 and maximum charge is $25. By using Nomad-A-What, you agree to our <a href='http://www.nomadawhat.com/legal'>community rules and terms of use</a>"
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :open_door_message) do |rec|
  rec.target_text = "To open our door, please start by providing us your cell phone number. If you have already done this, your Door Dashboard is active at the link we sent you via SMS."
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :use_sms_directions_html) do |rec|
  rec.target_text = "You should have received an SMS message with a link to your dashboard. Please <a href='%{sms_resend_link}'>click here</a> to resend the SMS, or contact us if you are still having trouble."
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :company_name) do |rec|
  rec.target_text = "Nomad-a-What"
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :session_started) do |rec|
  rec.target_text = "Your session has started! Please don't forget to check out when you're done."
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :greeting_header) do |rec|
  rec.target_text = 'Please fill in your profile details so we can get you started. All fields are required.'
  rec.save
end

CmsConfig.find_or_create_by(source_symbol: :checked_out) do |rec|
  rec.target_text = 'Checked out!'
  rec.save
end
