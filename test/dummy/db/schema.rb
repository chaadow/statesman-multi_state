# frozen_string_literal: true

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

ActiveRecord::Schema[7.0].define(version: 20_221_005_223_432) do
  create_table 'admin_status_order_transitions', force: :cascade do |t|
    t.string 'to_state', null: false
    t.text 'metadata', default: '{}'
    t.integer 'sort_key', null: false
    t.integer 'order_id', null: false
    t.boolean 'most_recent', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[order_id most_recent], name: 'index_admin_status_order_transitions_parent_most_recent', unique: true,
                                      where: 'most_recent'
    t.index %w[order_id sort_key], name: 'index_admin_status_order_transitions_parent_sort', unique: true
  end

  create_table 'orders', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'user_status_order_transitions', force: :cascade do |t|
    t.string 'to_state', null: false
    t.text 'metadata', default: '{}'
    t.integer 'sort_key', null: false
    t.integer 'order_id', null: false
    t.boolean 'most_recent', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[order_id most_recent], name: 'index_user_status_order_transitions_parent_most_recent', unique: true,
                                      where: 'most_recent'
    t.index %w[order_id sort_key], name: 'index_user_status_order_transitions_parent_sort', unique: true
  end

  add_foreign_key 'admin_status_order_transitions', 'orders'
  add_foreign_key 'user_status_order_transitions', 'orders'
end
