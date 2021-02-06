# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_06_214754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "conversations", force: :cascade do |t|
    t.string "conversable_type"
    t.bigint "conversable_id"
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversable_type", "conversable_id"], name: "index_conversations_on_conversable_type_and_conversable_id"
    t.index ["receiver_id"], name: "index_conversations_on_receiver_id"
    t.index ["sender_id", "receiver_id", "conversable_type", "conversable_id"], name: "unique_index_for_sender", unique: true
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "category", default: "bug"
    t.text "message"
    t.string "url"
    t.string "status", default: "normal"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "itineraries", force: :cascade do |t|
    t.string "slug"
    t.string "description"
    t.integer "num_people"
    t.integer "fuel_cost", default: 0
    t.integer "tolls", default: 0
    t.boolean "daily", default: false
    t.boolean "pink", default: false
    t.boolean "pets_allowed", default: false
    t.boolean "round_trip", default: false
    t.boolean "smoking_allowed", default: false
    t.datetime "leave_date"
    t.datetime "return_date"
    t.string "driver_gender"
    t.boolean "verified", default: false
    t.string "start_address"
    t.string "end_address"
    t.string "overview_polyline"
    t.geography "start_location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.geography "end_location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.geography "via_waypoints", limit: {:srid=>4326, :type=>"multi_point", :geographic=>true}
    t.geography "overview_path", limit: {:srid=>4326, :type=>"line_string", :geographic=>true}
    t.boolean "avoid_highways", default: false
    t.boolean "avoid_tolls", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_itineraries_on_slug", unique: true
    t.index ["user_id"], name: "index_itineraries_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "sender_id"
    t.text "body"
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "bio"
    t.date "birthday"
    t.string "gender"
    t.string "image"
    t.jsonb "languages", default: [], array: true
    t.string "name"
    t.string "locale"
    t.boolean "send_email_messages", default: false
    t.string "telephone"
    t.string "time_zone", default: "UTC"
    t.decimal "vehicle_avg_consumption", precision: 5, scale: 2, default: "0.12"
    t.boolean "admin", default: false
    t.boolean "banned", default: false
    t.string "access_token"
    t.datetime "access_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "feedbacks", "users"
  add_foreign_key "itineraries", "users"
end
