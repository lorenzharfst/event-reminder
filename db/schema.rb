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

ActiveRecord::Schema[8.1].define(version: 2026_05_20_231603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "event_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "fan_id", null: false
    t.datetime "sent_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_notifications_on_event_id"
    t.index ["fan_id"], name: "index_event_notifications_on_fan_id"
    t.index ["sent_at"], name: "index_event_notifications_on_sent_at"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "event_date"
    t.string "location"
    t.bigint "performer_id", null: false
    t.datetime "updated_at", null: false
    t.string "venue"
    t.index ["performer_id"], name: "index_events_on_performer_id"
  end

  create_table "fans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_fans_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "distance"
    t.bigint "fan_id", null: false
    t.string "location"
    t.bigint "performer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["fan_id"], name: "index_notifications_on_fan_id"
    t.index ["performer_id"], name: "index_notifications_on_performer_id"
  end

  create_table "performers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_performers_on_user_id"
  end

  create_table "routing_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination"
    t.decimal "distance_km"
    t.decimal "duration_minutes"
    t.text "error_message"
    t.string "origin"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_notifications", "events"
  add_foreign_key "event_notifications", "fans"
  add_foreign_key "events", "performers"
  add_foreign_key "fans", "users"
  add_foreign_key "notifications", "fans"
  add_foreign_key "notifications", "performers"
  add_foreign_key "performers", "users"
  add_foreign_key "sessions", "users"
end
