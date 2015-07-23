class SmsJob < ActiveJob::Base
  # Class for all jobs related to doing a readability parse
  queue_as :sms_messages
  include Rails.application.routes.url_helpers

  def perform(link_obj, temp_secret)
    # the twilio integration goes here
    # put your own credentials here
    account_sid = Rails.application.secrets.twilio_account_sid
    auth_token = Rails.application.secrets.twilio_auth_token

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    user = link_obj.user
    phone_no = user.is_international? ? "+#{user.phone_number}" : user.phone_number
    begin
      resp = @client.account.messages.create({
                                               from: Rails.application.secrets.twilio_account_phone,
                                               to: phone_no,
                                               body: "Your #{I18n.t(:company_name)} Door Dashboard: #{url_for(controller: 'dashboard', action: 'dash', link_secret: temp_secret)}",
                                             })
    rescue Twilio::REST::RequestError => e
      user.invalid_phone_number!
    end
  end
end
