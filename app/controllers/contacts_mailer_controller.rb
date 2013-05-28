class ContactsMailerController < ActionController::Base
  before_filter :check_credential

  # Submits an incoming email to ContactsMailer
  def index
    options = params.dup
    email = options.delete(:email)
    if ContactsMailer.receive(email, options)
      render :nothing => true, :status => :created
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end

  private

  def check_credential
    User.current = nil
    unless Setting.mail_handler_api_enabled? && params[:key].to_s == Setting.mail_handler_api_key
      render :text => 'Access denied. Incoming emails WS is disabled or key is invalid.', :status => 403
    end
  end
end
