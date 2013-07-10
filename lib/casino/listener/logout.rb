require 'casino/listener'

class CASino::Listener::Logout < CASino::Listener
  def user_logged_out(url, redirect_immediately = false)
    assign(:current_user, nil)
    if redirect_immediately
      @controller.redirect_to url, status: :see_other
    else
      assign(:url, url)
    end
    @controller.cookies.delete :tgt
  end
end
