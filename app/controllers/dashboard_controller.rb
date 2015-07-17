class DashboardController < ApplicationController
  before_action :require_link_secret
  layout 'dashboard'
  
  def dash
  end

  def open_sesame
    if @user.has_active_session?
      door_open_attempt!
    else
      flash[:alert] = 'No active session. Maybe you want to check in first?'
    end

    redirect_to "/dash/#{@user.plain_secret}"
  end

  def checkin
    # Cannot check in if they can't pay
    if PaymentTokenRecord.find_by_user_id(@user.id)
      PaidSession.create!(user: @user, active: true, started_at: Time.now.utc)
      flash[:notice] = config_or_locale(:session_started)
      door_open_attempt!
    else
      flash[:alert] = "error: We couldn't find payment information. Let us know if we got something wrong!"
    end

    redirect_to "/dash/#{@user.plain_secret}"
  end
  
  def checkout
    if @user.inactivate_sessions!
      notice_mesg = t(:checked_out)
      PrepareInvoicesJob.perform_later(@user)
    else
      alert_mesg = 'failure'
    end

    redirect_to "/dash/#{@user.plain_secret}", alert: alert_mesg, notice: notice_mesg
  end

  private
  def door_open_attempt!
    flash[:alert] ||= ''
    flash[:notice] ||= ''
    
    d = DoorMonitorRecord.new
    d.requestor = @user
    status = DoorGenie.open_door
    
    d.door_response = status
    if status == DoorGenie::DoorGenieStatus::OPENED
      DoorEntryMailer.admin_notification_email(@user).deliver_later
      flash[:notice] += " #{config_or_locale(:door_is_open)}"
    elsif status == DoorGenie::DoorGenieStatus::FAILED
      flash[:alert] += ' Sorry, the door did not open. Please try again.'
    elsif status == DoorGenie::DoorGenieStatus::AFTER_HOURS
      flash[:notice] += " #{config_or_locale(:after_hours_message)}"
    end
    
    d.save
  end
end
