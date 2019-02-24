class AddGitPuppetSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :puppet_init_path, :string, default: ''
    add_column :app_settings, :puppet_classes_path, :string, default: ''
    add_column :app_settings, :puppet_nodes_path, :string, default: ''
  end
end
