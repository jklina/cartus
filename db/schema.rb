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

ActiveRecord::Schema.define(version: 2020_07_05_204353) do

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.boolean "read", default: false, null: false
    t.bigint "user_id", null: false
    t.bigint "initiator_id", null: false
    t.text "message", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["initiator_id"], name: "index_notifications_on_initiator_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "recipient_id"
    t.index ["recipient_id"], name: "index_posts_on_recipient_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.integer "sentiment", default: 0, null: false
    t.bigint "user_id"
    t.string "content_type"
    t.bigint "content_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_type", "content_id"], name: "index_reactions_on_content_type_and_content_id"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "related_id"
    t.bigint "relatee_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "accepted", default: false, null: false
    t.index ["related_id"], name: "index_relationships_on_related_id"
    t.index ["relatee_id"], name: "index_relationships_on_relatee_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "first_name"
    t.string "last_name"
    t.date "birthday"
    t.integer "gender"
    t.string "email_confirmation_token", default: "", null: false
    t.datetime "email_confirmed_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "images", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "initiator_id"
  add_foreign_key "posts", "users"
  add_foreign_key "posts", "users", column: "recipient_id"
  add_foreign_key "relationships", "users", column: "related_id"
  add_foreign_key "relationships", "users", column: "relatee_id"
end
