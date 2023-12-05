# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false, default: ''
      t.string :password, null: false, default: ''

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
