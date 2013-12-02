# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130613185145) do

  create_table "ci_sessions", primary_key: "session_id", force: true do |t|
    t.string  "ip_address",    limit: 16,  default: "0", null: false
    t.string  "user_agent",    limit: 150,               null: false
    t.integer "last_activity",             default: 0,   null: false
    t.text    "user_data",                               null: false
  end

  create_table "email_add_to_project_queue", force: true do |t|
    t.integer "user_id",  null: false
    t.integer "user_id2", null: false
    t.integer "proj_id",  null: false
  end

  create_table "email_invite_to_scigit_queue", force: true do |t|
    t.integer "user_id",                null: false
    t.integer "proj_id",                null: false
    t.string  "to",         limit: 100, null: false
    t.integer "permission",             null: false
    t.string  "hash",       limit: 64,  null: false
  end

  add_index "email_invite_to_scigit_queue", ["proj_id"], name: "proj_id", using: :btree
  add_index "email_invite_to_scigit_queue", ["user_id"], name: "user_id", using: :btree

  create_table "email_queue", force: true do |t|
    t.integer "change_id", null: false
  end

  add_index "email_queue", ["change_id"], name: "change_id", using: :btree

  create_table "email_user_queue", force: true do |t|
    t.integer "user_id", null: false
  end

  add_index "email_user_queue", ["user_id"], name: "user_id", using: :btree

  create_table "login_attempts", force: true do |t|
    t.string    "ip_address", limit: 40, null: false
    t.string    "login",      limit: 50, null: false
    t.timestamp "time",                  null: false
  end

  create_table "migrations", id: false, force: true do |t|
    t.integer "version", null: false
  end

  create_table "proj_changes", force: true do |t|
    t.integer "proj_id",     null: false
    t.integer "user_id",     null: false
    t.string  "commit_msg",  null: false
    t.string  "commit_hash", null: false
    t.integer "commit_ts",   null: false
  end

  add_index "proj_changes", ["proj_id"], name: "pc_proj_index", using: :btree

  create_table "proj_permissions", force: true do |t|
    t.integer "user_id",    null: false
    t.integer "proj_id",    null: false
    t.integer "permission", null: false
  end

  add_index "proj_permissions", ["proj_id"], name: "proj_id", using: :btree
  add_index "proj_permissions", ["user_id"], name: "user_id", using: :btree

  create_table "proj_permissions_temp", force: true do |t|
    t.integer "user_id",    null: false
    t.integer "proj_id",    null: false
    t.integer "permission", null: false
  end

  add_index "proj_permissions_temp", ["proj_id"], name: "proj_id", using: :btree
  add_index "proj_permissions_temp", ["user_id"], name: "user_id", using: :btree

  create_table "project_changes", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "commit_msg"
    t.string   "commit_hash"
    t.integer  "commit_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_permissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_auth_tokens", force: true do |t|
    t.integer "user_id",    null: false
    t.string  "auth_token", null: false
    t.string  "ip_address", null: false
    t.integer "created_ts", null: false
    t.integer "expiry_ts",  null: false
  end

  add_index "user_auth_tokens", ["expiry_ts"], name: "token_expiry", using: :btree
  add_index "user_auth_tokens", ["user_id", "auth_token"], name: "token_index", unique: true, using: :btree

  create_table "user_autologin", id: false, force: true do |t|
    t.string    "key_id",     limit: 32,              null: false
    t.integer   "user_id",                default: 0, null: false
    t.string    "user_agent", limit: 150,             null: false
    t.string    "last_ip",    limit: 40,              null: false
    t.timestamp "last_login",                         null: false
  end

  create_table "user_invites", force: true do |t|
    t.integer "proj_id",                null: false
    t.string  "to",         limit: 100, null: false
    t.integer "permission",             null: false
    t.string  "hash",       limit: 64,  null: false
  end

  add_index "user_invites", ["proj_id"], name: "proj_id", using: :btree

  create_table "user_profiles", force: true do |t|
    t.integer "user_id",            null: false
    t.string  "country", limit: 20
    t.string  "website"
  end

  create_table "user_pub_keys", force: true do |t|
    t.integer "user_id",                                null: false
    t.string  "name",                                   null: false
    t.string  "key_type",                               null: false
    t.string  "public_key",     limit: 512,             null: false
    t.string  "comment",                                null: false
    t.integer "auto_generated",             default: 1, null: false
    t.integer "enabled",                    default: 1, null: false
  end

  add_index "user_pub_keys", ["public_key"], name: "pk_key_index", unique: true, using: :btree
  add_index "user_pub_keys", ["user_id"], name: "pk_user_index", using: :btree

  create_table "user_public_keys", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "key_type"
    t.string   "public_key", limit: 512
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "enabled"
  end

  add_index "user_public_keys", ["user_id"], name: "index_user_public_keys_on_user_id", using: :btree

  create_table "user_seen", force: true do |t|
    t.integer "user_id",             null: false
    t.string  "key",     limit: 100, null: false
    t.integer "value",               null: false
  end

  add_index "user_seen", ["key"], name: "key", using: :btree
  add_index "user_seen", ["user_id"], name: "user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fullname"
    t.string   "organization"
    t.string   "location"
    t.string   "about"
    t.boolean  "disable_email"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
