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

ActiveRecord::Schema[7.1].define(version: 2023_11_22_042337) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness', unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'activejob_web_job_approval_requests', force: :cascade do |t|
    t.integer 'job_execution_id'
    t.integer 'approver_id'
    t.integer 'response'
    t.string 'approver_comments'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'activejob_web_job_approvers', id: false, force: :cascade do |t|
    t.uuid 'job_id'
    t.integer 'approver_id'
  end

  create_table 'activejob_web_job_executions', force: :cascade do |t|
    t.integer 'requestor_id'
    t.uuid 'job_id'
    t.string 'requestor_comments'
    t.json 'arguments'
    t.integer 'status'
    t.string 'reason_for_failure'
    t.boolean 'auto_execute_on_approval'
    t.datetime 'run_at', precision: nil
    t.datetime 'execution_started_at', precision: nil
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
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
    t.string 'email', default: '', null: false
    t.string 'password', default: '', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
end
