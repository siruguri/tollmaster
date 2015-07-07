class InvoiceMailer < ActionMailer::Base
  include CmsConfigHelper
  helper CmsConfigHelper
  
  default(from: config_or_locale(:company_admin_email_from),
          subject: "Invoice for #{config_or_locale(:company_name)} Door Pass")

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
        mail(from: config_or_locale(:company_admin_email_from), to: user.email)
      end
    end
  end
end
