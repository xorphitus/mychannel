# -*- coding: utf-8 -*-
class StoriesController < ApplicationController
  include Authentication

  def emit
    # TODO これが重そうなので5分キャッシュとかしよう
    me = FbGraph::User.me(@access_token).fetch
    render json: Story.get(me)
  end
end
