# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  include Authentication

  def emit
    # TODO これが重そうなので5分キャッシュとかしよう
    me = FbGraph::User.me(@access_token).fetch
    render :json => Topic.get(me)
  end
end
