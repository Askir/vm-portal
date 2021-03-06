# frozen_string_literal: true

class AddGitPuppetSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :puppet_init_path, :string
    add_column :app_settings, :puppet_classes_path, :string
    add_column :app_settings, :puppet_nodes_path, :string
  end
end
