class DashboardController < ApplicationController
  before_action :require_link_secret
  layout 'dashboard'
  
  def dash
  end

  def open_sesame
    payload = {}
    if @user.has_active_session?
      d = DoorMonitorRecord.new
      d.requestor = @user
      if DoorGenie.open_door
        d.door_response = true
        alert = 'Door opened'
        DoorEntryMailer.admin_notification_email(@user).deliver_later
      else
        d.door_response = false
        alert = 'error: The door did not open. Sorry. Try again.'
      end
      d.save
    else
      alert = 'error: There was no active session. Maybe you want to check in first?'
    end
    
    redirect_to "/dash/#{@secret_link.secret}", alert: alert
  end

  def checkin
    # Cannot check in if they can't pay
    if PaymentTokenRecord.find_by_user_id(@user.id)
      PaidSession.create!(user: @user, active: true, started_at: Time.now.utc)
      alert_mesg = 'your session has started!'
    else
      alert_mesg = "error: We couldn't find payment information. Let us know if we got something wrong!"
    end

    redirect_to "/dash/#{@secret_link.secret}", alert: alert_mesg
  end
  
  def checkout
    if @user.inactivate_sessions!
      alert_mesg = 'checked out!'
      PrepareInvoicesJob.perform_later(@user)
    else
      alert_mesg = 'failure'
    end

    redirect_to "/dash/#{@secret_link.secret}", alert: alert_mesg
  end
end
