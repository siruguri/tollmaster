
class CardRecordsController < ApplicationController
  before_action :check_params, only: :create
  
  def create
    v = SecretLink.find_by_encrypted_secret(params[:link_secret]).user
    
    unless (tok_rec = PaymentTokenRecord.find_by_token_value(params[:payment_token_record][:token_value]))
      tok_rec = PaymentTokenRecord.new params[:payment_token_record].permit(:token_processor, :token_value)
      tok_rec.user = v
    end

    alert = notice = nil
    if tok_rec.user != v
      # If somehow this credit card was used by someone else - this only happens if we have a new user with an
      # Existing token record.
      alert = t(:credit_card_duplicate)
    else
      v.save_split_email! params[:username]
      v.email = params[:email_address]
      v.save!
      
      if !tok_rec.persisted? 
        tok_rec.save!
        notice = t(:credit_card_info_saved)
      end
    end
    
    redirect_to dash_path(link_secret: params[:link_secret]), notice: notice, alert: alert
  end

  def show
    @payment = Payment.find params[:id]
  end

  private
  def check_params
    if !(params[:email_address].blank?) and
       !(params[:username].blank?) and
       params[:link_secret] and params[:payment_token_record] and params[:payment_token_record][:token_value]
      if !SecretLink.find_by_encrypted_secret(params[:link_secret]).nil?
        return true
      end
    end
    
    render nothing: true, status: :bad_request
    return false
  end
end
