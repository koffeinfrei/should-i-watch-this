class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end
  helper_method :current_user

  def quote
    @quote ||= Quote.random
  end
  helper_method :quote


  def require_auth
    return if current_user

    redirect_to root_path, status: :forbidden
  end
end
