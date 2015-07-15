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
      if v.first_name.blank? and v.last_name.blank?
        v.save_split_name params[:username]
      end
      v.email = params[:email_address]

      # skip_confirmation! is done when the user has their first SMS sent
      v.skip_reconfirmation!
      v.save!

      notice = t(:credit_card_info_saved)
    end
    
    redirect_to dash_path(link_secret: params[:link_secret]), notice: notice, alert: alert
  end

  private
  def check_params
    if params[:link_secret] and
      !(sl = SecretLink.find_by_encrypted_secret(params[:link_secret])).nil?
      user = sl.user
      if !(user.email.blank? and params[:email_address].blank?) and
         !(user.first_name.blank? && user.last_name.blank? && params[:username].blank?) and
         params[:payment_token_record] and params[:payment_token_record][:token_value]
        return true
      end
    end

    # No secret link
    render nothing: true, status: :bad_request
    return false
  end
end
