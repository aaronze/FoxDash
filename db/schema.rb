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

ActiveRecord::Schema[7.0].define(version: 2026_05_12_071432) do
  create_table "dashboard_layouts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.json "layout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_dashboard_layouts_on_user_id"
  end

  create_table "telemetries", force: :cascade do |t|
    t.datetime "timestamp", null: false
    t.float "inverter_temperature"
    t.float "battery_temperature"
    t.float "battery_soc"
    t.float "power_load"
    t.float "grid_feed_in"
    t.float "grid_consumption"
    t.float "battery_discharge_rate"
    t.float "battery_charge_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timestamp"], name: "index_telemetries_on_timestamp", unique: true
  end

  add_foreign_key "dashboard_layouts", "users"
end
