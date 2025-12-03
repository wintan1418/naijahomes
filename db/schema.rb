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

ActiveRecord::Schema[7.2].define(version: 2025_12_03_224922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_favourites_on_property_id"
    t.index ["user_id", "property_id"], name: "index_favourites_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "lead_activities", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.integer "activity_type"
    t.text "description"
    t.json "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_lead_activities_on_lead_id"
    t.index ["user_id"], name: "index_lead_activities_on_user_id"
  end

  create_table "lead_notes", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "note_type", default: 0
    t.index ["lead_id"], name: "index_lead_notes_on_lead_id"
    t.index ["note_type"], name: "index_lead_notes_on_note_type"
    t.index ["user_id"], name: "index_lead_notes_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "assigned_to_id"
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.text "message", null: false
    t.string "source", default: "web_form", null: false
    t.integer "status", default: 0, null: false
    t.datetime "follow_up_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority"
    t.integer "lead_source"
    t.decimal "budget"
    t.text "lost_reason"
    t.index ["assigned_to_id"], name: "index_leads_on_assigned_to_id"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["property_id"], name: "index_leads_on_property_id"
    t.index ["status"], name: "index_leads_on_status"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "payment_frequency", default: 0, null: false
    t.integer "property_type", null: false
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "toilets"
    t.decimal "size", precision: 10, scale: 2
    t.string "state", null: false
    t.string "city", null: false
    t.string "lga"
    t.string "address", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "status", default: 0, null: false
    t.boolean "featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_properties_on_city"
    t.index ["featured"], name: "index_properties_on_featured"
    t.index ["latitude", "longitude"], name: "index_properties_on_latitude_and_longitude"
    t.index ["price"], name: "index_properties_on_price"
    t.index ["property_type"], name: "index_properties_on_property_type"
    t.index ["state"], name: "index_properties_on_state"
    t.index ["status"], name: "index_properties_on_status"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number", null: false
    t.integer "role", default: 0, null: false
    t.string "company_name"
    t.string "whatsapp_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "favourites", "properties"
  add_foreign_key "favourites", "users"
  add_foreign_key "lead_activities", "leads"
  add_foreign_key "lead_activities", "users"
  add_foreign_key "lead_notes", "leads"
  add_foreign_key "lead_notes", "users"
  add_foreign_key "leads", "properties"
  add_foreign_key "leads", "users", column: "assigned_to_id"
  add_foreign_key "properties", "users"
end
