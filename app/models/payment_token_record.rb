class PaymentTokenRecord < ActiveRecord::Base
  belongs_to :user

  validates :token_value, presence: true
end
