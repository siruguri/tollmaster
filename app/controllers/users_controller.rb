class UsersController < ApplicationController
  before_action :require_link_secret

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
