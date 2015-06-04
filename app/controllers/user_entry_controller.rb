class UserEntryController < ApplicationController
  before_action :check_params, only: [:authenticate, :resend_sms]

  def show
    @publishable_stripe_key = ENV['STRIPE_PUBLISHABLE_KEY']
  end

  def authenticate
    if(@user=User.find_by_phone_number(params[:primary_key]))
      @partial_name = 'known_user'
    else
      @partial_name = 'unknown_user'
    end

    render :entry_bottom, layout: false
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
