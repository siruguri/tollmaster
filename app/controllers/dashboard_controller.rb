class DashboardController < ApplicationController
  before_action :require_link_secret
  layout 'dashboard'
  
  def dash
    @is_after_hours = DoorGenie.is_after_hours?
    @stripe_publishable_key = Rails.application.secrets.stripe_publishable_key
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
    if @user.has_valid_token?
      PaidSession.create!(user: @user, active: true, started_at: Time.now.utc)
      flash[:notice] = config_or_locale(:session_started)
      door_open_attempt!(message: "(with checkin)")
    else
      flash[:alert] = "error: We couldn't find payment information. Let us know if we got something wrong!"
    end

    redirect_to "/dash/#{@user.plain_secret}"
  end
  
  def checkout
    if @user.inactivate_sessions!
      notice_mesg = config_or_locale(:checked_out)
      PrepareInvoicesJob.perform_later(@user)
      TrackingMailer.tracking_email("User #{@user.email} checked out").deliver_later
    else
      alert_mesg = 'failure'
    end

    redirect_to "/dash/#{@user.plain_secret}", alert: alert_mesg, notice: notice_mesg
  end

  private
  def door_open_attempt!(message: '')
    flash[:alert] ||= ''
    flash[:notice] ||= ''
    
    d = DoorMonitorRecord.new
    d.requestor = @user
    status = DoorGenie.open_door
    
    d.door_response = status
    if status == DoorGenie::DoorGenieStatus::OPENED
      flash[:notice] += " #{config_or_locale(:door_is_open)}"
      mail_mesg = "#{config_or_locale(:door_is_open)}"
    elsif status == DoorGenie::DoorGenieStatus::FAILED
      flash[:alert] += ' Sorry, the door did not open. Please try again.'
      mail_mesg = 'Sorry, the door did not open. Please try again.'
    elsif status == DoorGenie::DoorGenieStatus::AFTER_HOURS
      flash[:notice] += " #{config_or_locale(:after_hours_message)}"
      mail_mesg = "#{config_or_locale(:after_hours_message)}"
    end

    DoorEntryMailer.admin_notification_email(@user, mail_mesg + message).deliver_later
    d.save
  end
end
