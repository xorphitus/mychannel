module FbGraphExtension
  class User < FbGraph::User
    attr_accessor :user_id

    def initialize endidentifier, attributes = {}
      super endidentifier, attributes
      @user_id = attributes[:id]
    end
  end
end
