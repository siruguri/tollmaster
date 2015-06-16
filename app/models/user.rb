class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  validates_uniqueness_of :phone_number, allow_nil: true
  has_many :paid_sessions
  after_create :make_secret_link!

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
    if (first_name and first_name.strip.length > 0) or (last_name and last_name.strip.length > 0)
      ret = (first_name.strip.length > 0 ? "#{first_name} " : "") + last_name
    elsif phone_number && phone_number.length > 0
      ret = phone_number
    else # Devise guarantees email exists and is non-blank
      ret = email[0..20] + (email.length < 20 ? '' : "...")
    end
  end

  def make_invoices
    i = Invoice.new(amount: 0.0)
    begin
      ActiveRecord::Base.transaction do      
        paid_sessions.where(invoice_id: nil).select { |s| s.is_inactive? }.each do |session|
          i.paid_sessions << session
          i.amount += session.session_cost
        end

        if i.amount > 0
          # At least one session above was inactive
          i.invoice_status = Invoice::InvoiceStatus::CREATED
          i.payer = self
          i.save!
        end
      end
    rescue Exception => e
      puts "\n\nDidn't save: #{e}"
      # Guess I'll ignore it for now? An invoicing will be attempted next time
      # the user checks out.
    end
  end

  def make_secret_link!
    # create a new secret link record for the user.
    s=SecretLink.new
    s.user = self
    s.save!

    s.persisted?
  end

  def has_token?
    @has_token ||= PaymentTokenRecord.where(user_id: id).count > 0
  end

  def needs_name?
    first_name.blank? and last_name.blank?
  end

  def needs_email?
    email.blank?
  end
end
