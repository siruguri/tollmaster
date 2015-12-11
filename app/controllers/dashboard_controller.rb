class DashboardController < ApplicationController
  before_action :require_link_secret
  layout 'dashboard'
  
  def dash
    @is_after_hours = DoorGenie.is_after_hours?
    @stripe_publishable_key = Rails.application.secrets.stripe_publishable_key
  end

  def open_sesame
    if @user.has_active_session?
      mail_mesg = door_open_attempt!
      DoorEntryMailer.admin_notification_email(@user, mail_mesg).deliver_later
    else
      flash[:alert] = 'No active session. Maybe you want to check in first?'
    end

    redirect_to dash_path(link_secret: @user.plain_secret)
  end

  def checkin
    # Cannot check in if they can't pay
    if @user.has_valid_token?
      PaidSession.create!(user: @user, active: true, started_at: Time.now.utc)
      flash[:notice] = config_or_locale(:session_started)
      mail_mesg = door_open_attempt!
      DoorEntryMailer.admin_notification_email(@user, mail_mesg + "(with checkin)").deliver_later      
    else
      flash[:alert] = "error: We couldn't find payment information. Let us know if we got something wrong!"
    end

    redirect_to dash_path(link_secret: @user.plain_secret)
  end
  
  def checkout
    if @user.inactivate_sessions!
      notice_mesg = config_or_locale(:checked_out)
      PrepareInvoicesJob.perform_later(@user)
      TrackingMailer.tracking_email("User #{@user.email} with phone #{@user.phone_number} checked out").deliver_later
    else
      alert_mesg = 'failure'
    end

    flash[:alert] = alert_mesg; flash[:notice] = notice_mesg
    redirect_to dash_path(link_secret: @user.plain_secret)
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
      flash[:notice] += " #{config_or_locale(:door_is_open)}"
      mail_mesg = "#{config_or_locale(:door_is_open)}"
    elsif status == DoorGenie::DoorGenieStatus::FAILED
      flash[:alert] += ' Sorry, the door did not open. Please try again.'
      mail_mesg = 'Sorry, the door did not open. Please try again.'
    elsif status == DoorGenie::DoorGenieStatus::AFTER_HOURS
      flash[:notice] += " #{config_or_locale(:after_hours_message)}"
      mail_mesg = "#{config_or_locale(:after_hours_message)}"
    end

    d.save
    mail_mesg
  end
end
