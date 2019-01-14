# frozen_string_literal: true

class UsersController < ApplicationController
  include UsersHelper

  before_action :authenticate_current_user, only: %i[edit update]
  before_action :authenticate_current_user_or_admin, only: %i[show]
  before_action :authenticate_admin, only: %i[index update_role]

  def index
    @users = User.all
  end

  def show; end

  def edit; end

  def update
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
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user == @user
  end

  def authenticate_current_user_or_admin
    @user = User.find(params[:id])
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user == @user || current_user&.admin?
  end
end
