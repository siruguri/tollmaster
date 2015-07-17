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

ActiveRecord::Schema.define(version: 20150716053018) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true

  create_table "cms_configs", force: :cascade do |t|
    t.string "source_symbol"
    t.text   "target_text"
  end

  create_table "door_monitor_records", force: :cascade do |t|
    t.integer  "requestor_id"
    t.integer  "door_response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "payer_id"
    t.float    "amount"
    t.integer  "invoice_status"
    t.datetime "pay_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "navbar_entries", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "paid_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "started_at"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_id"
    t.datetime "ended_at"
  end

  create_table "payment_token_records", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token_processor"
    t.string   "token_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer_id"
    t.boolean  "disabled",        default: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "payment_token_record_id"
    t.integer  "amount"
    t.datetime "payment_date"
    t.string   "payment_for"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "secret_links", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.string   "confirmation_token"
    t.string   "unconfirmed_email"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "phone_number"
    t.boolean  "invalid_phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_international"
  end

  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
