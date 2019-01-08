# frozen_string_literal: true

class RequestsController < ApplicationController
  include OperatingSystemsHelper
  before_action :set_request, only: %i[show edit update destroy]
  before_action :authenticate_employee
  before_action :authenticate_admin, only: %i[request_accept_button]

  # GET /requests
  # GET /requests.json
  def index
    # TODO: This needs to be changed in a different PR to a filtered version.
    # Therefore distinguish between admin and employee
    @requests = Request.all
  end

  # GET /requests/1
  # GET /requests/1.json
  def show; end

  # GET /requests/new
  def new
    @request = Request.new
    @request_templates = RequestTemplate.all
  end

  # GET /requests/1/edit
  def edit; end

  def notify_users(title, message)
    User.all.each do |each|
      each.notify(title, message)
    end
  end

  def redirect_according_to_role(format, role)
    if role == 'admin'
      format.html { redirect_to @request, notice: 'Request was successfully created.' }
    else
      format.html { redirect_to dashboard_url, notice: 'Request was successfully created.' }
    end
  end

  def successfully_saved(format, request)
    notify_users('New VM request', request.description_text(host_url))
    redirect_according_to_role(format, current_user.role)
    format.json { render :show, status: :created, location: request }
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    save_sudo_rights(@request)

    respond_to do |format|
      if @request.save
        successfully_saved(format, @request)
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def notify_request_update(request)
    return if request.pending?

    if request.accepted?
      notify_users('Request has been accepted', @request.description_text(host_url))
    elsif request.rejected?
      message = @request.description_text host_url
      message += request.rejection_information.empty? ? '' : "\nwith comment: #{request.rejection_information}"
      notify_users('Request has been rejected', message)
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      if @request.update(request_params)
        notify_request_update(@request)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def request_accept_button
    @request = Request.find(params[:request])
    @request.accept!
    if @request.save
      notify_request_update(@request)
      redirect_to new_vm_path(request: @request)
    else
      redirect_to request_path(@request)
    end
  end

  private

  def save_sudo_rights(request)
    sudo_users_for_request = request.users_assigned_to_requests.select { |uatq| request_params[:sudo_user_ids].include?(uatq.user_id.to_s) }

    sudo_users_for_request.each do |association|
      association.sudo = true
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.require(:request).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :operating_system,
                                    :port, :application_name, :comment, :rejection_information, :status, user_ids: [], sudo_user_ids: [])
  end
end
