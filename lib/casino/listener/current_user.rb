require 'casino/listener'

class CASino::Listener::CurrentUser < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def current_user(user)
    assign(:current_user, user)
  end
end
