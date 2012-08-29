class DashboardController < ApplicationController
  include Authentication

  def index
    @me = FbGraph::User.me(@access_token).fetch
  end
end
