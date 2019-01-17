# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_employee, only: %i[new create]
  before_action :authenticate_responsible_user, only: %i[edit update]

  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
    @current_user = current_user
  end

  # POST /requests.json
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to action: :index
    else
      render :new, locals: { selected_users: [current_user] }
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to action: :show
    else
      render :edit
    end
  end

  private

  def authenticate_responsible_user
    @project = Project.find(params[:id])
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless @project.responsible_users.include? current_user
  end

  def project_params
    params.require(:project).permit(:name, :description, responsible_user_ids: [])
  end
end