class Invoice < ActiveRecord::Base
  class InvoiceStatus
    CREATED = 0
    SENT_TO_PAYER = 1
    CHARGED = 2
    CHARGE_FAILED = 3
  end

  has_many :paid_sessions
  belongs_to :payer, class_name: 'User'
end
