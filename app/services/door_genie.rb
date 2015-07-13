class DoorGenie
  class DoorGenieStatus
    OPENED = 0
    AFTER_HOURS = 1
    FAILED = 2
  end
  
  def self.open_door
    # Only opens during business hours, if set
    if Rails.application.secrets.start_of_day_24h and
      Time.now < (Date.today + Rails.application.secrets.start_of_day_24h.hours) or
      Rails.application.secrets.end_of_day_24h and
      Time.now > (Date.today + Rails.application.secrets.end_of_day_24h.hours)
      return DoorGenieStatus::AFTER_HOURS
    end
    
    begin
      a = Net::HTTP.get(URI(Rails.application.secrets.iobridge_door_open_url))

      if Rails.env.development?
        puts a[0..32]
      end
    rescue Errno::ETIMEDOUT, Timeout::Error, Errno::ECONNRESET, SocketError => e1
      return DoorGenieStatus::FAILED
    else
      return DoorGenieStatus::OPENED
    end
  end
end
