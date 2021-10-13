# frozen_string_literal: true

class StoreAllScoresOneTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :scores, :score, :integer

    add_column :scores, :rank_solo, :integer
    add_column :scores, :rank_in_batch, :integer
    add_column :scores, :rank_in_city, :integer

    add_column :scores, :score_solo, :integer
    add_column :scores, :score_in_batch, :integer
    add_column :scores, :score_in_city, :integer

    drop_table :batch_scores do |t|
      t.references :batch, null: false, foreign_key: true
      t.integer :day, limit: 1
      t.integer :challenge, limit: 1
      t.references :user, null: false, foreign_key: true
      t.integer :completion_unix_time, limit: 8
      t.integer :score
      t.datetime :updated_at, precision: 6, null: false
    end

    drop_table :city_scores do |t|
      t.references :city, null: false, foreign_key: true
      t.integer :day, limit: 1
      t.integer :challenge, limit: 1
      t.references :user, null: false, foreign_key: true
      t.integer :completion_unix_time, limit: 8
      t.integer :score
      t.datetime :updated_at, precision: 6, null: false
    end
  end
end
