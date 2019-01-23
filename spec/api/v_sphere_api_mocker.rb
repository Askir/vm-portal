# frozen_string_literal: true

require 'rails_helper'
require './app/api/v_sphere/folder'
require './app/api/v_sphere/virtual_machine'
require './app/api/v_sphere/cluster'
require './app/api/v_sphere/host'

# This file contains a few helper methods which allow for easy mocking of instances of the vSphere module
#
# To mock the entire VSphere API in one go, create new VSphere::Connection with
#   connection = v_sphere_connection_mock [<normal vms>], [<archived vms>], [<pending_archivation_vms>]
#   allow(VSphere::Connection).to receive(:instance).and_return connection
# After that you can use the VSphere module pretty much as normal
#
# You can use the v_sphere_vm_mock method to mock vms
#
# You can also use v_sphere_folder_mock method to mock folders in vSphere, note however that the mocks cannot create
# new subfolders and are generally pretty much limited to containing VMs or other folders
#
# Any methods that contain vim in their name are used to mock the internal objects of the vSphere API/rbvmomi and
# should not be used directly!

# We really want to be able to stub message chains in this file, because the API that is provided by vSphere
# has many messages that have to be chained which we want to mock.
# rubocop:disable RSpec/MessageChain

def extract_vim_objects(collection)
  collection.map do |each|
    if [VSphere::Cluster, VSphere::Folder, VSphere::VirtualMachine].include? each.class
      each.instance_exec { managed_folder_entry }
    else
      each
    end
  end
end

def vim_folder_mock(name, subfolders, vms, clusters) # rubocop:disable Metrics/AbcSize
  children = subfolders + vms + clusters
  children = extract_vim_objects children
  folder = double
  allow(folder).to receive(:name).and_return(name)
  allow(folder).to receive(:children).and_return(children)
  allow(folder).to receive(:is_a?).and_return false
  allow(folder).to receive(:is_a?).with(RbVmomi::VIM::Folder).and_return true
  folder
end

def v_sphere_folder_mock(name, subfolders: [], vms: [], clusters: [])
  VSphere::Folder.new vim_folder_mock(name, subfolders, vms, clusters)
end

def vim_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled', boot_time: Time.now - 60*60*24, hearteat_status: 'green',
                guest_id: 'Win10', guest_name: 'Win10 EE', host_name: 'ibmesx13.eaalab.hpi.uni-potsdam.de', committed_storage: 100, uncommitted_storage: 100,
                cpu_usage: 50, cpu_reservation: 100, guest_memory_usage: 1024, memory_size: 2024, cpu_number: 1) # rubocop:disable Metrics/AbcSize
  vm = double
  allow(vm).to receive(:name).and_return(name)
  allow(vm).to receive(:guestHeartbeatStatus).and_return(hearteat_status)
  allow(vm).to receive(:is_a?).and_return false
  allow(vm).to receive(:is_a?).with(RbVmomi::VIM::VirtualMachine).and_return true
  allow(vm).to receive_message_chain(:runtime, :powerState).and_return power_state
  allow(vm).to receive_message_chain(:guest, :toolsStatus).and_return vm_ware_tools
  allow(vm).to receive_message_chain(:runtime, :bootTime).and_return boot_time
  allow(vm).to receive_message_chain(:summary, :config, :guestId).and_return guest_id
  allow(vm).to receive_message_chain(:summary, :config, :guestFullName).and_return guest_name
  allow(vm).to receive_message_chain(:summary, :runtime, :host, :name).and_return host_name
  allow(vm).to receive_message_chain(:summary, :storage, :committed).and_return committed_storage
  allow(vm).to receive_message_chain(:summary, :storage, :uncommitted).and_return uncommitted_storage
  allow(vm).to receive_message_chain(:summary, :quickStats, :overallCpuUsage).and_return cpu_usage
  allow(vm).to receive_message_chain(:summary, :config, :cpuReservation).and_return cpu_reservation
  allow(vm).to receive_message_chain(:summary, :quickStats, :guestMemoryUsage).and_return guest_memory_usage
  allow(vm).to receive_message_chain(:summary, :config, :memorySizeMB).and_return memory_size
  allow(vm).to receive_message_chain(:summary, :config, :numCpu).and_return cpu_number

  vm
end

def v_sphere_vm_mock(name, power_state: 'poweredOn', vm_ware_tools: 'toolsNotInstalled', boot_time: Time.now - 60*60*24)
  VSphere::VirtualMachine.new vim_vm_mock(name,
                                          power_state: power_state,
                                          vm_ware_tools: vm_ware_tools,
                                          boot_time: boot_time)
end

def vim_host_mock(name)
  host = double
  allow(host).to receive(:name).and_return name
  host
end

def v_sphere_host_mock(name)
  VSphere::Host.new vim_host_mock(name)
end

def vim_cluster_mock(name, hosts) # rubocop:disable Metrics/AbcSize
  hosts = extract_vim_objects hosts
  cluster = double
  allow(cluster).to receive(:is_a?).and_return false
  allow(cluster).to receive(:is_a?).with(RbVmomi::VIM::ComputeResource).and_return true
  allow(cluster).to receive(:host).and_return hosts
  allow(cluster).to receive(:name).and_return name
  cluster
end

def v_sphere_cluster_mock(name, hosts)
  VSphere::Cluster.new vim_cluster_mock(name, hosts)
end

def v_sphere_connection_mock(normal_vms, archived_vms, pending_archivation_vms, pending_revivings_vms, clusters)
  archived_vms_folder = v_sphere_folder_mock 'Archived VMs', vms: archived_vms
  pending_archivation_vms_folder = v_sphere_folder_mock 'Pending archivings', vms: pending_archivation_vms
  pending_reviving_vms_folder = v_sphere_folder_mock 'Pending revivings', vms: pending_revivings_vms
  root_folder = v_sphere_folder_mock 'root', subfolders: [archived_vms_folder, pending_archivation_vms_folder,
                                                          pending_reviving_vms_folder], vms: normal_vms
  clusters_folder = v_sphere_folder_mock 'clusters', clusters: clusters
  double_connection = double
  allow(double_connection).to receive(:root_folder).and_return root_folder
  allow(double_connection).to receive(:clusters_folder).and_return clusters_folder
  double_connection
end

# rubocop:enable RSpec/MessageChain
