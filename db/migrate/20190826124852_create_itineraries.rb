class CreateItineraries < ActiveRecord::Migration[5.2]
  def change
    create_table :itineraries do |t|
      t.string :slug

      # Details
      t.string :description
      t.integer :num_people
      t.integer :fuel_cost, default: 0
      t.integer :tolls, default: 0

      t.boolean :daily,           default: false
      t.boolean :pink,            default: false
      t.boolean :pets_allowed,    default: false
      t.boolean :round_trip,      default: false
      t.boolean :smoking_allowed, default: false

      t.datetime :leave_date
      t.datetime :return_date

      # Cached user details (for filtering purposes)
      t.string :driver_gender
      t.boolean :verified, default: false

      # Route from Google Directions Service
      t.string :start_address
      t.string :end_address
      t.string :overview_polyline
      t.st_point :start_location, geographic: true
      t.st_point :end_location, geographic: true
      t.multi_point :via_waypoints, geographic: true
      t.line_string :overview_path, geographic: true

      t.boolean :avoid_highways, default: false
      t.boolean :avoid_tolls, default: false

      t.references :user, foreign_key: true

      t.timestamps null: false
    end

    add_index :itineraries, :slug, unique: true
  end
end
