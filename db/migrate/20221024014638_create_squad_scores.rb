class CreateSquadScores < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :squad_scores do |t|
      t.integer :score
      t.references :squad, null: false, foreign_key: true
      t.timestamp :cache_key

      t.timestamps
    end

    add_index :squad_scores, :cache_key, algorithm: :concurrently
    add_index :squad_scores, [:squad_id, :cache_key], unique: true
  end
end
