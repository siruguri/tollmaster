class CardRecordsController < ApplicationController
  before_action :check_params, only: :create
  
  def create
    u = User.find_by_phone_number(params[:primary_key]) || User.new(phone_number: params[:primary_key])
    if u.new_record?
      u.email = params[:email_address] || "email_#{u.phone_number}@rockitcolabs.com"
      u.password = Devise.bcrypt(User, 'password')
      u.skip_confirmation!
    end
    
    unless (tok_rec = PaymentTokenRecord.find_by_token_value(params[:payment_token_record][:token_value]))
      tok_rec = PaymentTokenRecord.new params[:payment_token_record].permit(:token_processor, :token_value)
      tok_rec.user = u
    end

    if tok_rec.user != u
      # If somehow this credit card was used by someone else - this only happens if we have a new user with an
      # Existing token record.
      redirect_to root_path, alert: "Credit card already used in our system"
    else
      begin
        ActiveRecord::Base.transaction do
          if !u.persisted?
            u.save!
          end
          if !tok_rec.persisted? 
            tok_rec.save!

            # We have a token - time to send the secret link.
            s=SecretLink.new
            s.user = u
            s.save!
          end
        end
      rescue ActiveRecord::RecordInvalid
        # For now we don't have a condition where these records can be invalid when saved.
        # Don't know what other type of exception to catch ... some sort of DBConnectionLost error?
      end
      
      render nothing: true, status: :success
    end
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
