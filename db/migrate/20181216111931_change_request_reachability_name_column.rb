# frozen_string_literal: true

class ChangeRequestReachabilityNameColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :requests, :reachability_name, :application_name
  end
end