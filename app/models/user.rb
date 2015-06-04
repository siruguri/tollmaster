class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_uniqueness_of :phone_number, allow_nil: true
  has_many :paid_sessions
  
  def secret_link
    (s=SecretLink.joins(:user).where(user: self)).empty? ? nil : s.order(created_at: :desc).first
  end

  def has_active_session?
    a=Date.today
    t=Time.new(a.year, a.month, a.day)
    
    !(PaidSession.where(active: true, user_id: self.id).where('started_at > ?', t).empty?)
  end

  def invalid_phone_number!
    self.invalid_phone_number = true
    self.save
  end

  def inactivate_sessions!
    # There can always only be one active session for the day
    a=Date.today
    t=Time.new(a.year, a.month, a.day)
    
    active_session = PaidSession.where(active: true, user_id: self.id).where('started_at > ?', t).first
    if active_session
      active_session.active = false
      active_session.ended_at = Time.now
      active_session.save
    end

    if !active_session or !active_session.persisted?
      false
    else
      true
    end
  end

  def displayable_greeting
    ret = nil
    if phone_number && phone_number.length > 0
      ret = phone_number
    else # Devise guarantees email exists and is non-blank
      ret = email[0..20] + (email.length < 20 ? '' : "...")
    end
  end
end
