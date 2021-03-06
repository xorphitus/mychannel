class SessionsController < ApplicationController
  before_filter :require_authentication, only: :destroy
  before_filter :require_not_authentication, only: :new

  # display login page
  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    login

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # logout
  def destroy
    reset_session

    respond_to do |format|
      format.html { redirect_to new_session_url }
    end
  end

  private
  def login
    fb_auth = FbGraph::Auth.new(Settings.fb.app_id, Settings.fb.app_secret)
    fb_auth.from_cookie(cookies)
    login_as(fb_auth.user.identifier, fb_auth.access_token.access_token)
  end

  def login_as fb_user_id, access_token
    session[:fb_user_id] = fb_user_id
    session[:access_token] = access_token
  end

  def require_not_authentication
    redirect_to root_url if authenticated?
  end
end
