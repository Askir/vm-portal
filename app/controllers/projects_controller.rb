# frozen_string_literal: true

class ProjectsController < ApplicationController
  @@resource_name = Project.model_name.human.titlecase

  before_action :authenticate_employee, only: %i[new create]
  before_action :authenticate_responsible_user, only: %i[edit update destroy]

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
    @selected_user_ids = [current_user.id]
  end

  # POST /requests.json
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, notice: t('flash.create.notice', resource: @@resource_name, model: @project.name)
      @project.responsible_users.each do |each|
        each.notify('Project created',
                    "The project #{@project.name} with you as the responsible has been created.",
                    url_for(controller: :projects, action: 'show', id: @project.id))
      end
    else
      @selected_user_ids = project_params[:responsible_user_ids]
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project, notice: t('flash.update.notice', resource: @@resource_name, model: @project.name)
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    if @project.destroy
      notice = t('flash.destroy.notice', resource: @@resource_name, model: @project.name)
    else
      alert = t('flash.destroy.alert', resource: @@resource_name, model: @project.name)
    end
    redirect_to projects_path, notice: notice, alert: alert
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
