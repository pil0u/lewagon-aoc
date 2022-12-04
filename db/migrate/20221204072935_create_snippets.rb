class CreateSnippets < ActiveRecord::Migration[7.0]
  def change
    create_table :snippets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day
      t.integer :challenge
      t.text :language
      t.text :code

      t.timestamps
      t.index %i[user_id day challenge language], unique: true
    end
  end
end
