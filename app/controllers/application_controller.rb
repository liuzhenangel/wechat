class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  private
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    if wechat? && ( current_user.blank? || current_user.wechat_openid.blank? )
      logout
      redirect_to '/auth/wechat'
      return
    end

    if ! wechat? && ( current_user.blank? || current_user.open_wechat_openid.blank? )
      logout
      redirect_to '/auth/open_wechat'
      return
    end

    if current_user.lock?
      logout
      redirect_to root_path, :alert => '你的帐号已被锁定, 如有疑问, 请通过公众号 The8020Rule 与我们取得联系'
      return
    end
  end

  def authenticate_admin!
    if !current_user
      redirect_to root_path, :alert => '请先登录'
      return
    end

    if !current_user.admin?
      redirect_to root_path, :alert => '没有权限'
    end
  end

  def store_location
    if request.xhr? or ! request.get?
      return
    end

    if( request.path != signout_path &&
       request.path !~ /^\/auth\// &&
       request.path !~ /^\/sessions\// )
      session[:return_to] = request.fullpath
    end
  end

  def redirect_back_or_default(default)
    path = session.delete(:return_to)
    logger.debug("redirect to #{path}")
    redirect_to(path || default)
  end

  def login_as(user)
    session[:user_id] = user.id
    cookies.signed[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
    cookies.signed[:user_id] = nil
  end
  def wechat?
    browser.wechat?
  end

  def mobile?
    browser.device.mobile?
  end
end
