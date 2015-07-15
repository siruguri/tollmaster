class Invoice < ActiveRecord::Base
  class InvoiceStatus
    CREATED = 0
    SENT_TO_PAYER = 1
    CHARGED = 2
    CHARGE_FAILED = 3
    ATTEMPT_CHARGE = 4
  end

  has_many :paid_sessions, dependent: :destroy
  belongs_to :payer, class_name: 'User'

  def wrapped_save!
    # Special save to enable testing of failed invoice charging
    save!
  end
end
