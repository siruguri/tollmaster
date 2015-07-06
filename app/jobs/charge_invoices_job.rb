class ChargeInvoicesJob < ActiveJob::Base
  queue_as :invoices
  
  def perform(user)
    # Find all invoices sent to user by mail, and charge with the user's token.
    threshold = Rails.application.secrets.minimum_invoice_amount

    if user == 'all'
      # Prepare invoices for all users
      uncharged_users = User.joins(:invoices).includes(:invoices).
                        where('invoices.invoice_status = ?', Invoice::InvoiceStatus::SENT_TO_PAYER).uniq
    else
      uncharged_users = [ user ]
    end

    # Ignore users we cannot charge
    uncharged_users.each do |user|
      unless (cust_id = user.stripe_customer_id).nil?
        uncharged_invoices = user.invoices.where(invoice_status: Invoice::InvoiceStatus::SENT_TO_PAYER)
        total = uncharged_invoices.all.inject(0) { |sum, inv| sum += inv.amount }
        if total > threshold
          uncharged_invoices.each do |i|
            invalid_request = false
            begin
              status = Stripe::Charge.create(customer: cust_id,
                                             amount: total.to_i,
                                             currency: 'usd',
                                             description: i.id)
            rescue Stripe::CardError
              i.invoice_status = Invoice::InvoiceStatus::CHARGE_FAILED
            rescue Stripe::InvalidRequestError => e
              Rails.logger.info("Invalid request error #{e.message} using invoice #{i.inspect}")
              invalid_request = true
            else
              i.invoice_status = Invoice::InvoiceStatus::CHARGED
            end

            unless invalid_request
              i.save
            end
          end
        end
      end
    end
  end
end
