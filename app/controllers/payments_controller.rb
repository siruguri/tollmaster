class PaymentsController < ApplicationController
  def create
    
    Stripe::Charge.create(
      :amount => params[:amount],
      :currency => "usd",
      :source => tok_rec.token_value,
      :description => "Charge for test@example.com"
    )
    
    @payment = Payment.create(payment_token_record: tok_rec, amount: params[:amount], payment_date: Time.now)
  end
end
