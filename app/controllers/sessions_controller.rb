class SessionsController < ApplicationController

  #FIXME delete me when test over
  def login_for_admin
    user = User.find_by(role: :admin)
    login_as(user)
    flash[:notice] = '登录成功'
    redirect_to admin_root_path
  end

  def create
    auth = request.env["omniauth.auth"]
    # unionid SHOULD exist, so we fetch directly
    logger.debug auth
    unionid = auth.extra.raw_info.unionid
    raise "No unionid found, please check omniauth configure!" if unionid.blank?
    user = User.where(uid: unionid.to_s).first
    if user.present?
      user.update_user_info(auth)
    else
      user = User.create_with_wechat(auth, unionid)
    end

    login_as(user)

    if auth.provider == 'wechat'
      if user.wechat_openid.blank?
        user.wechat_openid = auth.uid
        user.save(validate: false)
      end
      redirect_back_or_default(root_path)
    elsif auth.provider == 'open_wechat'
      if user.open_wechat_openid.blank?
        user.open_wechat_openid = auth.uid
        user.role = :writer if user.role.to_sym == :reader
        user.save(validate: false)
      end
      redirect_to writer_root_path
    end
  end

  def destroy
    logout()
    redirect_to root_path, :notice => '注销成功'
  end

  def failure
    logger.info("session#failure #{params[:message]}")
    redirect_to root_path, :alert => "你取消了授权"
  end

end
