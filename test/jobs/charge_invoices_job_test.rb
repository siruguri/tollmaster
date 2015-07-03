require 'test_helper'

class ChargeInvoicesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    set_net_stubs
  end
  
  test 'Can charge invoices for one user' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 2) do
      ChargeInvoicesJob.perform_now users(:user_1)
    end
  end

  test 'Can avoid users without tokens' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 0) do
      ChargeInvoicesJob.perform_now users(:user_2)
    end
  end

  test 'Can charge all valid users in one go' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 3) do
      ChargeInvoicesJob.perform_now 'all'
    end
  end

end
