# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  include Authentication

  # POST
  def create
    @user = User.new(params[:user])
    @user.fb_id = get_fb_me.user_id

    respond_to do |format|
      if @user.save
        format.html { redirect_to :channels, notice: "保存しました" }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { redirect_to :channels, alert: @user.errors }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT
  def update
    @user = User.find(params[:id])
    @user.fb_id = get_fb_me.user_id

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to :channels, notice: "保存しました" }
        format.json { head :no_content }
      else
        format.html { redirect_to :channels, alert: @user.errors }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
