class StripeCustomerIdJob < ActiveJob::Base
  queue_as :stripe_interactions

  def perform(ptr_inst)
    begin
      customer = Stripe::Customer.create(
        source: ptr_inst.token_value,
        description: "Customer record for #{ptr_inst.user.username}")
      ptr_inst.customer_id = customer.id
      ptr_inst.save
    rescue Stripe::InvalidRequestError => e
      Rails.logger.info("Found error when requesting customer ID for token #{ptr_inst.token_value}")
    end
  end
end

    
