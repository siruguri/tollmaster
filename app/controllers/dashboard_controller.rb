class DashboardController < ApplicationController
  before_action :require_link_secret
  
  def dash
    if @user.has_active_session?
      @payment_option = :check_out
    else
      @payment_option = :check_in
    end
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
    else
      alert_mesg = 'failure'
    end

    redirect_to "/dash/#{@secret_link.secret}", alert: alert_mesg
  end

  private
  def require_link_secret
    unless params[:link_secret] && (@secret_link = SecretLink.find_by_secret(params[:link_secret]))
      redirect_to root_path, alert: 'Something went wrong. Please contact us if you think your link should have worked.'

      return false
    end

    @user = @secret_link.user
    true
  end
end
