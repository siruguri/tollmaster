class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include CmsConfigHelper
  
  protect_from_forgery with: :exception

  before_action do
    # Quite a few things to do before the app starts...
    I18n.locale = set_locale
    insert_default_param_filter
  end

  rescue_from ActionController::RoutingError do |exception|
    error_message = I18n.t(:message_404)
    go_back_or_root(error_message)
  end
  protected
  def require_link_secret
    unless params[:link_secret] && (@secret_link = SecretLink.find_by_encrypted_secret(params[:link_secret]))
      redirect_to root_path, alert: 'Something went wrong. Please contact us if you think your link should have worked.'

      return false
    end

    @user = @secret_link.user
    @user.plain_secret = params[:link_secret]
    true
  end

  private
  def set_locale
    # 1. Let's make our app use the locale
    
    params[:locale] || I18n.default_locale
  end

  def insert_default_param_filter
    # 2. This helps Rails4 strong parameter setting
    resource = controller_name.singularize.to_sym
    method = "#{resource}_strong_params"

    params[resource] &&= send(method, params[resource]) if respond_to?(method, true)
  end

  def go_back_or_root(message)
    if request.env.key? "HTTP_REFERER"
      redirect_to :back, :alert => message
    else
      redirect_to root_url, :alert => message
    end
  end 

  # Use URL options to set locale. I prefer it that way.
  def self.default_url_options(options={})
    { locale: I18n.locale }
  end
end
