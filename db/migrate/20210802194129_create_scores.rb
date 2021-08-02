class CreateScores < ActiveRecord::Migration[6.1]
  def change
    create_table :scores do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day, limit: 1
      t.integer :challenge, limit: 1
      t.integer :completion_unix_time, limit: 8
      t.integer :score

      t.timestamps
    end
  end
end
