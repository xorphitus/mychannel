class SessionsController < ApplicationController
  before_filter :require_authentication, only: [:destroy]

  # display login page
  def new
  end

  # logout
  def destroy
    redirect_to "https://www.facebook.com/logout.php?next=#{root_url}&access_token=#{@access_token}"
  end
end
