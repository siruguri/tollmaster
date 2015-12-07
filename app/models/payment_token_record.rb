class PaymentTokenRecord < ActiveRecord::Base
  belongs_to :user

  validates :token_value, presence: true

  after_create :get_stripe_customer_id, unless: 'customer_id.present?'

  def get_stripe_customer_id
    unless self.customer_id
      StripeCustomerIdJob.perform_later self
    end
  end
end
