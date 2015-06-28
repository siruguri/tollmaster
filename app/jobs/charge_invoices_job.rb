class ChargeInvoicesJob < ActiveJob::Base
  queue_as :invoices
  
  def perform(user)
    # Find all invoices sent to user by mail, and charge with the user's token.

    # Ignore users we cannot charge
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
