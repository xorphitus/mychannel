class SessionsController < ApplicationController
  before_filter :require_authentication, only: [:destroy]

  # display login page
  def new
    redirect_to root_url if authenticated?
  end

  def create
    login
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # logout
  def destroy
    logout
    redirect_to root_url
  end
end
