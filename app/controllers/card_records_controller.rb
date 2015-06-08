class CardRecordsController < ApplicationController
  before_action :check_params, only: :create
  
  def create
    v = User.find_by_phone_number(params[:primary_key]) || User.new(phone_number: params[:primary_key])
    if v.new_record?
      v.email = params[:email_address] || "email_#{v.phone_number}@rockitcolabs.com"
      v.password = Devise.bcrypt(User, 'password')
      v.skip_confirmation!
    end
    
    unless (tok_rec = PaymentTokenRecord.find_by_token_value(params[:payment_token_record][:token_value]))
      tok_rec = PaymentTokenRecord.new params[:payment_token_record].permit(:token_processor, :token_value)
      tok_rec.user = v
    end

    alert = notice = ''
    if tok_rec.user != v
      # If somehow this credit card was used by someone else - this only happens if we have a new user with an
      # Existing token record.
      alert = "Credit card already used in our system"
    else
      begin
        ActiveRecord::Base.transaction do
          if !v.persisted?
            v.save!
          end
          if !tok_rec.persisted? 
            tok_rec.save!

            # We have a token - time to send the secret link.
            s=SecretLink.new
            s.user = v
            s.save!
          end
        end

        notice = t(:use_sms_directions_html,
                   sms_resend_link: user_entry_resend_sms_path(primary_key: v.phone_number)).html_safe
      rescue ActiveRecord::RecordInvalid
        # For now we don't have a condition where these records can be invalid when saved.
        # Don't know what other type of exception to catch ... some sort of DBConnectionLost error?
        notice = 'Something went wrong. Please try again!'
      end
      
    end
    redirect_to root_path, notice: notice, alert: alert
  end

  def show
    @payment = Payment.find params[:id]
  end

  private
  def check_params
    if !params[:payment_token_record] or !params[:payment_token_record][:token_value]
      render nothing: true, status: :bad_request
      return false
    end

    true
  end
end
