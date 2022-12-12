class AddCompletionsInsertedToState < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :states, :completions_fetched, :integer
    add_index :states, :completions_fetched, algorithm: :concurrently
  end
end
