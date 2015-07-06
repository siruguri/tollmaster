class User < ActiveRecord::Base
  attr_accessor :plain_secret
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  validates_uniqueness_of :phone_number, allow_nil: true
  has_many :paid_sessions, dependent: :destroy
  has_many :secret_links, dependent: :destroy
  has_many :invoices, foreign_key: 'payer_id', dependent: :destroy
  has_one :payment_token_record, dependent: :destroy
  after_create :make_secret_link!

  def valid_secret_link
    secret_links.empty? ? nil : secret_links.order(created_at: :desc).first
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
    
    active_sessions = PaidSession.where(active: true, user_id: self.id).where('started_at > ?', t).all
    succesful_inactivations = 0

    if (orig_count = active_sessions.count) > 0
      active_sessions.each do |session|
        session.active = false
        session.ended_at = Time.now
        session.save
        succesful_inactivations += 1
      end
    end

    if succesful_inactivations != orig_count
      false
    else
      true
    end
  end

  def username
    # Allows for checking that username in form becomes the right username in the model
    if (first_name and first_name.strip.length > 0) or (last_name and last_name.strip.length > 0)
      (first_name.strip.length > 0 ? "#{first_name} " : "") + last_name
    else
      nil
    end
  end
  
  def displayable_greeting
    ret = nil
    if username
      username
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

    s
  end

  def reset_link!
    s=SecretLink.new
    s.user = self
    s.save!

    s
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

  def save_split_name(form_name)
    # Allow user models to save names from form
    form_name = form_name.strip
    if form_name.length > 0
      if /\s/.match(form_name)
        matches = /^(.+)\s([^\s]+)$/.match(form_name)
        self.first_name = matches[1]
        self.last_name = matches[2]
      else
        self.first_name = form_name
      end
    end
  end

  def stripe_customer_id
    if payment_token_record
      payment_token_record.customer_id
    else
      nil
    end
  end
end
