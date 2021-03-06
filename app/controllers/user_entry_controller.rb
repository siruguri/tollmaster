class UserEntryController < ApplicationController
  include PhoneNumberManager

  before_action :check_params, except: :show
  before_action :set_canonical_number, except: :show
  
  def show
    @stripe_publishable_key = Rails.application.secrets.stripe_publishable_key
  end

  def authenticate
    if(@user = User.find_by_phone_number @canonical_number[:number])
      @partial_name = 'known_user'
    else
      @partial_name = 'unknown_user'
    end

    render :entry_bottom, layout: false
  end

  def send_first_sms
    notice = alert = nil

    if User.find_by_phone_number @canonical_number[:number]
      notice = config_or_locale :youre_in_our_system
    else
      begin
        v = User.new

        # Take care of possible duplicates
        v.set_phone_number @canonical_number
        v.password = Devise::Encryptor.digest(User, 'password')
        v.skip_confirmation!

        v.save!
      rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid  => e
        alert = 'Failure. Please try again.'
      else
        notice = t(:first_use_sms_directions_html,
                   sms_resend_link: resend_sms_user_entry_path(primary_key: v.phone_number)).html_safe
      end
    end

    redirect_to root_path, notice: notice, alert: alert
  end
  
  def resend_sms
    @user = User.find_by_phone_number(@canonical_number[:number])

    if @user
      new_link = @user.make_secret_link!
    end
  end
  
  private
  def check_params
    unless params[:primary_key] 
      redirect_to :root
      return false
    end

    true
  end

  def set_canonical_number
    @canonical_number = canonicalize_number params[:primary_key]
  end
end
