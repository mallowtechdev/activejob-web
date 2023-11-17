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

ActiveRecord::Schema[7.1].define(version: 2023_11_01_105617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'activejob_web_job_approvers', id: false, force: :cascade do |t|
    t.uuid 'job_id'
    t.integer 'approver_id'
  end

  create_table 'activejob_web_job_executors', id: false, force: :cascade do |t|
    t.uuid 'job_id'
    t.integer 'executor_id'
  end

  create_table 'activejob_web_jobs', id: false, force: :cascade do |t|
    t.uuid 'id', default: -> { 'gen_random_uuid()' }, null: false
    t.string 'title'
    t.string 'description'
    t.json 'input_arguments'
    t.integer 'max_run_time'
    t.integer 'minimum_approvals_required'
    t.integer 'priority'
    t.integer 'queue'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'authors', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
