# -*- coding: utf-8 -*-
module FbGraphExtension
  # FbGraphのデフォルトだとユーザ情報にユーザのIDが含まれていないため
  # IDを付与したオブジェクトとなるように拡張
  class User < FbGraph::User
    attr_accessor :user_id

    def initialize endidentifier, attributes = {}
      super endidentifier, attributes
      @user_id = attributes[:id]
    end
  end
end
