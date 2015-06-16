class CardRecordsController < ApplicationController
  before_action :check_params, only: :create
  
  def create
    v = SecretLink.find_by_secret(params[:link_secret]).user
    
    unless (tok_rec = PaymentTokenRecord.find_by_token_value(params[:payment_token_record][:token_value]))
      tok_rec = PaymentTokenRecord.new params[:payment_token_record].permit(:token_processor, :token_value)
      tok_rec.user = v
    end

    alert = notice = nil
    if tok_rec.user != v
      # If somehow this credit card was used by someone else - this only happens if we have a new user with an
      # Existing token record.
      alert = "Credit card already used in our system"
    else
      if !tok_rec.persisted? 
        tok_rec.save!
      end
    end
    notice = t(:use_sms_directions_html,
               sms_resend_link: resend_sms_user_entry_path(primary_key: v.phone_number)).html_safe      

    redirect_to dash_path(link_secret: params[:link_secret]), notice: notice, alert: alert
  end

  def show
    @payment = Payment.find params[:id]
  end

  private
  def check_params
    if !params[:link_secret] or !params[:payment_token_record] or !params[:payment_token_record][:token_value] \
      or (params[:link_secret] and SecretLink.find_by_secret(params[:link_secret]).nil?)
      render nothing: true, status: :bad_request
      return false
    end

    true
  end
end
