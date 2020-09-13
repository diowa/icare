class RemoveFacebookColumnsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :facebook_data_cached_at, :datetime, default: "2012-09-06 00:00:00"
    remove_column :users, :facebook_favorites, :jsonb, default: [], array: true
    remove_column :users, :facebook_permissions, :jsonb, default: [], array: true
    remove_column :users, :facebook_verified, :boolean, default: false
  end
end
