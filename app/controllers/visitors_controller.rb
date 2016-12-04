class VisitorsController < ApplicationController
  before_action :authenticate_user!, only: [:test_for_new_user]

  def index
    if ENV['USER_TEST_DEBUG'].present? && params[:raw].blank?
      redirect_to '/test', notice: '用户测试已经被打开'
      return
    end
  end

  def route_not_found
    render 'pages/404', status: 404
  end

  def error500
    render 'pages/500', status: 500
  end

  def test
    @users = User.order(created_at: :asc)
  end

  def test_for_new_user
    @user = current_user
  end

  def test_for
    user = User.find(params[:id])
    if user.writer?
      login_as(user)
      user.open_wechat_openid = 'dummy_data'
      user.save(validate: false)
    else
      user.role = :writer
      user.open_wechat_openid = 'dummy_data'
      user.save(validate: false)
    end
    redirect_to writer_root_path, notice: '测试用户登录成功'
  end
end
