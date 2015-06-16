class InvoiceMailer < ActionMailer::Base
  default(from: "admin@rockitcolabs.com", subject: "Invoice for Rockit Door Pass")

  def invoice_email(user)
    # Find all invoices paid by this user, that are in created state, and mail them.
    @user = user
    @invoices = Invoice.where(payer_id: user.id, invoice_status: Invoice::InvoiceStatus::CREATED)

    update_success = true
    begin
      ActiveRecord::Base.transaction do
        @invoices.each do |invoice|
          invoice.invoice_status = Invoice::InvoiceStatus::SENT_TO_PAYER
          invoice.save!
        end
      end
    rescue ActiveRecord::Rollback => e
      update_success = false
    end

    if update_success
      if user.email and user.email.strip.size > 0
        mail(from: "admin@rockitcolabs.com", to: user.email)
      end
    end
  end
end
