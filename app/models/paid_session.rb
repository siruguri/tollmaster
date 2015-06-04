class PaidSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :invoice
  
  def duration(unit: :seconds)
    a = Date.today

    # Only active sessions or ones that started yesterday or earlier will yield a duration
    if !active || (started_at.year < a.year ||
                   started_at.month < a.month ||
                   started_at.day < a.day)
      if active
        duration = PaidSession.end_of_day - (started_at.hour * 3600 + started_at.min * 60 + started_at.sec)
      else
        duration = ended_at - started_at
      end
    else
      duration = 0
    end

    if duration == 0
      nil
    else
      if unit == :seconds
        duration
      else
        # For now we'll return milliseconds if the unit is unknown
        duration * 1000
      end
    end
  end

  def self.end_of_day
    # Official end of day has to be set
    Rails.application.secrets.end_of_day_24h.hour * 60 * 60
  end
end
