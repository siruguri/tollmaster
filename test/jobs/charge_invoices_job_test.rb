require 'test_helper'

class ChargeInvoicesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    set_net_stubs
    create_customer_id(:user_1)
    create_customer_id(:user_with_paid_session)
  end
  
  test 'Can charge invoices for one user' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 2) do
      ChargeInvoicesJob.perform_now users(:user_1)
    end
  end

  test 'Can avoid users without customer ids' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 0) do
      ChargeInvoicesJob.perform_now users(:user_2)
    end
  end

  test 'Can charge all valid users in one go' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 3) do
      ChargeInvoicesJob.perform_now 'all'
    end
  end

  private
  def create_customer_id(uid)
    p = users(uid).payment_token_record
    p.customer_id = 'validcustomerid'
    p.save!
  end    
end
