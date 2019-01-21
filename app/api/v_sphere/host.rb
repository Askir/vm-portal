# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'
require_relative 'cluster'

# This class wraps a rbvmomi Host and provides easy access to common operations
module VSphere
  class Host
    def self.all
      VSphere::Cluster.all.map(&:hosts).flatten
    end

    def initialize(rbvmomi_host)
      @host = rbvmomi_host
    end

    def vms
      @host.vm.map { |each| VSphere::VirtualMachine.new each }
    end

    def name
      @host.name
    end

    def model
      @host.hardware.systemInfo.model
    end

    def vendor
      @host.hardware.systemInfo.vendor
    end

    def boot_time
      @host.runtime.bootTime
    end

    def connection_state
      @host.runtime.connectionState
    end

    def summary
      @host.summary
    end

    def equal?(other)
      other.is_a?(VSphere::Host) && name == other.name
    end

    def ==(other)
      equal? other
    end

    private

    def managed_folder_entry
      @host
    end
  end
end
