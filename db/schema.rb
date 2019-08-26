# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_26_120019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.string "category", default: "bug"
    t.text "message"
    t.string "url"
    t.string "status", default: "open"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
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
    t.datetime "facebook_data_cached_at", default: "2012-09-06 00:00:00"
    t.jsonb "facebook_favorites", default: [], array: true
    t.jsonb "facebook_permissions", default: [], array: true
    t.boolean "facebook_verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "feedbacks", "users"
end
