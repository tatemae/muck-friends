class RemoveNameFields < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :first_name
    remove_column :profiles, :last_name
    add_column :profiles, :profile_views, :integer
    add_column :profiles, :policy, :text
  end

  def self.down
    add_column :profiles, :first_name, :string
    add_column :profiles, :last_name, :string
    remove_column :profiles, :profile_views
    remove_column :profiles, :policy
  end
end
