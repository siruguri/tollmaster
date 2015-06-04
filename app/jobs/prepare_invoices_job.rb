class PrepareInvoicesJob < ActiveJob::Base
  def perform
    unpaid_sessions = PaidSession.where invoice_id: nil

    us_by_user = unpaid_sessions.group_by { |sess| sess.user }

    @durations = {}
    us_by_user.each do |user, sessions|
      # Add the sessions lengths for this user, that either didn't start today
      # Or are inactive.
      @durations[user.id] = sessions.inject({invoice_sum: 0.0, payable_sessions: []}) do |memo, sess|
        if (i = sess.duration(unit: :seconds))
          memo[:invoice_sum] += i
          memo[:payable_sessions] << sess
        end
        memo
      end
    end

    # The durations decide the invoice amounts
    ActiveRecord::Base.transaction do
      @durations.select { |key, value| value[:invoice_sum] > 0 }.each do |user_id, payload|
        i = Invoice.create(user_id: user_id, amount: payload[:invoice_sum], invoice_status: Invoice::InvoiceStatus::CREATED)
        payload[:payable_sessions].each do |sess|
          i.paid_sessions << sess
        end
      end
    end
  end
end
