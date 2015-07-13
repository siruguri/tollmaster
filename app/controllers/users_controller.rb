class UsersController < ApplicationController
  before_action :require_link_secret, only: [:update]
  before_action :authenticate_admin!, except: [:update]
  
  def show_invoices
    @user_invoices = Invoice.joins(:payer).where('invoice_status = ?', Invoice::InvoiceStatus::SENT_TO_PAYER).
                     group(:payer_id).sum(:amount)

    @total = @user_invoices.inject(0) do |sum, amt|
      sum += amt[1]
    end
  end

  def charge_invoices
    ChargeInvoicesJob.perform_later('all')
    redirect_to show_invoices_users_path, notice: 'Charges sent to Stripe.'
  end
  
  def update
    updated = false
    update_ids = []

    if params[:email_address]
      @user.email = params[:email_address].strip
    end
    
    if params[:username]
      m = /(.*)\s+([^\s]+)$/.match(params[:username].strip)
      if m
        @user.first_name = m[1]
        @user.last_name = m[2]
      else
        @user.last_name = params[:username].strip
      end
    end
    
    if @user.valid?
      @user.skip_reconfirmation!
      ret = @user.save!
      updated = true
      update_ids = ['email_address', 'username'].select { |i| params[i.to_sym] and params[i.to_sym].strip.size > 0 }
    end

    render json: {updated: updated, update_ids: update_ids}
  end
end
