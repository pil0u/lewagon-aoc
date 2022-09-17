class AddSquadIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :squad_id, :integer
  end
end
