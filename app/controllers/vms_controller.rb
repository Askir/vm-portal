# frozen_string_literal: true

require 'vmapi.rb'

class VmsController < ApplicationController
  attr_reader :vms

  include VmsHelper

  def index
    @vms = filter VmApi.instance.all_vm_infos
    @archived_vms = all_archived_vms
    @parameters = determine_params
  end

  def destroy
    # params[:id] is actually the name of the vm, since the vsphere backend doesn't identify vms by IDs
    # VmApi.instance.delete_vm(params[:id])
  end

  def create
    VmApi.instance.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name])
    redirect_to action: :index
  end

  def new
    @request = !params[:request].nil? ? Request.find(params[:request]) : default_render
  end

  def show
    @vm = VmApi.instance.get_vm_info(params[:id])
    render(template: 'errors/not_found', status: :not_found) if @vm.nil?
  end

  def request_vm_archivation
    @vm = VmApi.instance.get_vm(params[:id])
    if is_archived(@vm) || is_pending_archivation(@vm)
      return
    end

    VmApi.instance.change_power_state(@vm.name, false)
    User.all.filter { |each| each.role == :admin }.each do |each|
      each.notify_slack("VM #{@vm.name} has been requested to be archived!")
    end
    set_pending_archivation(@vm)

    redirect_to controller: :vms, action: 'show', id: @vm.name
  end

  def change_power_state
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.change_power_state(@vm[:name], @vm[:state])
    redirect_to root_path
  end

  def suspend_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.suspend_vm(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def shutdown_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.shutdown_guest_os(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def reboot_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reboot_guest_os(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def reset_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reset_vm(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def filter(list)
    if no_params_set?
      list
    else
      result = []
      vm_filter.keys.each do |key|

        result += list.select { |object| vm_filter[key].call(object) } if params[key].present?
      end
      result
    end
  end

  def determine_params
    all_parameters = vm_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    if no_params_set?
      all_parameters
    else
      all_parameters - (all_parameters - actual_params)
    end
  end

  def no_params_set?
    all_parameters = vm_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    (all_parameters - actual_params).size == all_parameters.size
  end

  def vm_filter
    { up_vms: proc { |vm| vm[:state] }, down_vms: proc { |vm| !vm[:state] } }
  end
end
