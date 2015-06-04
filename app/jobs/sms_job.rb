class SmsJob < ActiveJob::Base
  # Class for all jobs related to doing a readability parse
  queue_as :sms_messages
  include Rails.application.routes.url_helpers

  def perform(user)
    # the twilio integration goes here
    # put your own credentials here
    account_sid = Rails.application.secrets.twilio_account_sid
    auth_token = Rails.application.secrets.twilio_auth_token

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    begin
      resp = @client.account.messages.create({
                                               from: Rails.application.secrets.twilio_account_phone,
                                               to: user.phone_number,
                                               body: "Your Rockit Dashboard: #{url_for(controller: 'dashboard', action: 'dash', link_secret: user.secret_link.secret)}",
                                             })
    rescue Twilio::REST::RequestError => e
      user.invalid_phone_number!
    end
  end
end
