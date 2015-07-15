class PaidSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :invoice, dependent: :destroy
  
  def duration(unit: :seconds)
    # inactive = sessions whose active attribute is false, OR ones that started yesterday or earlier will yield a duration
    if !is_inactive?
      nil
    else
      if active
        # The day ended without the session being checked out from
        duration = PaidSession.end_of_day - (started_at.hour * 3600 + started_at.min * 60 + started_at.sec)
      else
        duration = ended_at - started_at
      end

      if unit == :seconds
        duration
      else
        # For now we'll return milliseconds if the unit is unknown
        duration * 1000
      end
    end
  end

  def is_inactive?
    a = Date.today
    !active || (started_at.year < a.year ||
                   started_at.month < a.month ||
                   started_at.day < a.day)

  end
  
  def self.end_of_day
    # Official end of day has to be set
    Rails.application.secrets.end_of_day_24h * 60 * 60
  end

  def session_cost
    # Expects cost per second in cents
    basecost = duration(unit: :seconds).to_i * Rails.application.secrets.session_price_per_second

    if Rails.application.secrets.minimum_session_cost
      basecost = [Rails.application.secrets.minimum_session_cost, basecost].max
    end

    if Rails.application.secrets.maximum_session_cost
      basecost = [Rails.application.secrets.maximum_session_cost, basecost].min
    end

    basecost
  end
end
