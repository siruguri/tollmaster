require 'test_helper'

class ChargeInvoicesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    set_net_stubs
  end
  
  test 'Can charge invoices' do
    assert_difference('Invoice.where(invoice_status: Invoice::InvoiceStatus::CHARGED).count', 1) do
      ChargeInvoicesJob.perform_now users(:user_1)
    end
  end
end
