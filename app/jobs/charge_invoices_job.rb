class ChargeInvoicesJob < ActiveJob::Base
  queue_as :invoices
  
  def perform(user)
    # Find all invoices sent to user by mail, and charge with the user's token.

    if user == 'all'
      # Prepare invoices for all users
      unsent_users = User.joins(:invoices).
                     where('invoices.invoice_status = ? and invoices.amount > ?', Invoice::InvoiceStatus::SENT_TO_PAYER,
                           Rails.application.secrets.minimum_invoice_amount).uniq
    else
      unsent_users = [ user ]
    end

    # Ignore users we cannot charge
    unsent_users.each do |user|
      unless (token = user.payment_token_record).nil?
        invoices = Invoice.where(invoice_status: Invoice::InvoiceStatus::SENT_TO_PAYER, payer: user)
        invoices.each do |i|
          begin
            status = Stripe::Charge.create(source: token.token_value,
                                           amount: i.amount,
                                           currency: 'usd',
                                           description: i.id)
          rescue Stripe::CardError
            i.invoice_status = Invoice::InvoiceStatus::CHARGE_FAILED
          else
            i.invoice_status = Invoice::InvoiceStatus::CHARGED
          end

          i.save
        end
      end
    end
  end
end
