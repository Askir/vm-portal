# frozen_string_literal: true

class UsersController < ApplicationController
  include UsersHelper

  before_action :authenticate_current_user, only: [:edit]
  before_action :authenticate_admin, only: %i[index edit update update_role]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  def update_role
    @user = User.find(params[:id])
    @user.update(role: params[:role])
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:ssh_key)
  end

  def authenticate_current_user
    @user = User.find(params[:id])
    redirect_to @user unless current_user == @user
  end
end
