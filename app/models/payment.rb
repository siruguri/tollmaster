class Payment < ActiveRecord::Base
  belongs_to :payment_token_record

  validates :payment_date, presence: true
  validates :amount, presence: true, numericality: true
end
