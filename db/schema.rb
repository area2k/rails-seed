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

ActiveRecord::Schema.define(version: 2020_04_28_025113) do

  create_table "devices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "uuid", limit: 64, null: false
    t.string "refresh_token", limit: 32, null: false
    t.string "last_issued", limit: 32, null: false
    t.datetime "last_issued_at", null: false
    t.integer "expires_at", null: false
    t.string "user_agent", null: false
    t.string "ip", limit: 32
    t.string "client", limit: 32
    t.string "client_version", limit: 32
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["refresh_token"], name: "index_devices_on_refresh_token", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
    t.index ["uuid"], name: "index_devices_on_uuid", unique: true
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uuid", limit: 64, null: false
    t.string "email", limit: 128, null: false
    t.string "first_name", limit: 64
    t.string "last_name", limit: 64
    t.string "locale", limit: 8, default: "en-US", null: false
    t.string "password_digest", limit: 64
    t.string "password_reset_token", limit: 32
    t.boolean "password_stale", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

end
