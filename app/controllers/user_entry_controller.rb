class UserEntryController < ApplicationController
  include PhoneNumberManager

  before_action :check_params, except: :show
  before_action :set_canonical_number, except: :show
  
  def show
    @publishable_stripe_key = ENV['STRIPE_PUBLISHABLE_KEY']
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
        notice = t(:use_sms_directions_html).html_safe
      end
    end

    redirect_to root_path, notice: notice, alert: alert
  end
  
  def resend_sms
    @user = User.find_by_phone_number(params[:primary_key])

    if @user
      new_link = @user.reset_link!
      SmsJob.perform_later(new_link, new_link.temporary_secret)
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
