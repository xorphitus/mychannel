# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  include Authentication

  # POST
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to :channel, notice: "保存しました" }
        format.json { render json: @user, status: :created, location: @user }
      else
        #format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to :channels, notice: "保存しました" }
        format.json { head :no_content }
      else
        #format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
