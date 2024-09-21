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

ActiveRecord::Schema[7.2].define(version: 2024_09_21_075553) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "backup_notes", id: { type: :string, limit: 13 }, force: :cascade do |t|
    t.text "content"
    t.string "user_id", limit: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_backup_notes_on_user_id"
  end

  create_table "notes", id: { type: :string, limit: 12 }, force: :cascade do |t|
    t.text "content"
    t.string "slug", limit: 20
    t.string "external_slug", limit: 20
    t.integer "views", default: 0
    t.boolean "need_password", default: false
    t.string "hash_password", limit: 255
    t.boolean "temporary", default: true
    t.string "user_id", limit: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_slug"], name: "index_notes_on_external_slug", unique: true
    t.index ["slug"], name: "index_notes_on_slug", unique: true
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "users", id: { type: :string, limit: 12 }, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "username", limit: 255
    t.string "avatar", limit: 255, default: "https://i.imgur.com/iNsPoYP.jpg"
    t.string "hash_password", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "backup_notes", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "notes", "users", on_update: :cascade, on_delete: :cascade
end
