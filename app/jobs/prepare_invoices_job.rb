class PrepareInvoicesJob < ActiveJob::Base
  queue_as :invoices
  
  def perform(user)
    if user == :all
      # Prepare invoices for all users
      unpaid_user_ids = PaidSession.where(invoice_id: nil).joins(:user).pluck('users.id').uniq
    else
      unpaid_user_ids = [ user.id ]
    end

    unpaid_user_ids.each do |user_id|
      u = User.find(user_id)

      # Expect this to return false if something went wrong, so we can avoid sending an email
      if u.make_invoices
        InvoiceMailer.invoice_email(u).deliver_later
      end
    end
  end
end
