class AddPostgisExtension < ActiveRecord::Migration[5.2]
  def change
    enable_extension :postgis
  end
end
