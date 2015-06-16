class UserEntryController < ApplicationController
  before_action :check_params, except: :show

  def show
    @publishable_stripe_key = ENV['STRIPE_PUBLISHABLE_KEY']
  end

  def authenticate
    if(@user = User.find_by_phone_number(params[:primary_key]))
      @partial_name = 'known_user'
    else
      @partial_name = 'unknown_user'
    end

    render :entry_bottom, layout: false
  end

  def send_first_sms
    notice = alert = nil
    if User.find_by_phone_number params[:primary_key]
      notice = 'That number is already in our system.'
    else
      begin
        v = User.new(phone_number: params[:primary_key])
        v.password = Devise.bcrypt(User, 'password')
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
      SmsJob.perform_later(@user)
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
end
