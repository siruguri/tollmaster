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
        uncharged_invoices = user.invoices.where(invoice_status: Invoice::InvoiceStatus::SENT_TO_PAYER).all
        give_up = false

        # This prevents the possiblity of a double charge by sending invoices into a dead state that
        # They can be manually recovered from.
        uncharged_invoices.each do |i|
          i.invoice_status = Invoice::InvoiceStatus::ATTEMPT_CHARGE
        end

        begin
          ActiveRecord::Base.transaction do
            uncharged_invoices.each do |i|
              i.save!
            end
          end
        rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid => e
          give_up = true
        end
        
        total = uncharged_invoices.inject(0) { |sum, inv| sum += inv.amount }
        customer_id_list = uncharged_invoices.map { |i| i.id }.join(', ')

        failure = nil

        if !give_up && total > threshold
          begin
            status = Stripe::Charge.create(customer: cust_id,
                                           amount: total.to_i,
                                           currency: 'usd',
                                           description: "Invoices IDs# #{customer_id_list}")
          rescue Stripe::CardError
            failure = :stripe_card_error
          rescue Stripe::InvalidRequestError => e
            Rails.logger.info("Invalid request error #{e.message} using invoice #{i.inspect}")
            failure = :invalid_request
          end
        end

        uncharged_invoices.each do |i|
          if failure
            if failure == :stripe_card_error
              i.invoice_status = Invoice::InvoiceStatus::CHARGE_FAILED
            end
          else failure
            i.invoice_status = Invoice::InvoiceStatus::CHARGED
          end
        end

        begin
          ActiveRecord::Base.transaction do
            uncharged_invoices.each do |i|
              i.wrapped_save!
            end
          end
        rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid => e
        end
      end
    end
  end
end
