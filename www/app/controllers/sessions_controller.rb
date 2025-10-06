class SessionsController < Passwordless::SessionsController
  before_action :require_unauth, only: [:new, :show]

  def create
    user = User.find_or_initialize_by(email: normalized_email_param)

    if user.new_record?
      user.save!
    end

    super
  end

  private

  def require_unauth
    return unless current_user

    redirect_to root_path
  end
end
