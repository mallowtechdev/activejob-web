class ChangePrimaryKeyToUuid < ActiveRecord::Migration[7.1]
  def up
    remove_column :activejob_web_jobs, :id
    add_column :activejob_web_jobs, :id, :uuid, default: 'gen_random_uuid()', primary_key: true
  end

  def down
    remove_column :activejob_web_jobs, :id
    add_column :activejob_web_jobs, :id, :primary_key
  end
end
