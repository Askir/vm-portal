class MergeUserAndUserProfile < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    User.all.each do |user|
      if !user.nil?
        user.first_name = user.first_name
        user.last_name = user.last_name
      else
        user.first_name = 'Firstname'
        user.last_name = 'Lastname'
      end
      user.save
    end
    drop_table :user_profiles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
