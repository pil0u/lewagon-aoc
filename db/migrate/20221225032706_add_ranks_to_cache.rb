class AddRanksToCache < ActiveRecord::Migration[7.0]
  def change
    add_column :city_scores, :rank, :integer
    add_column :city_scores, :order, :integer
    add_column :insanity_scores, :rank, :integer
    add_column :insanity_scores, :order, :integer
    add_column :solo_scores, :rank, :integer
    add_column :solo_scores, :order, :integer
    add_column :squad_scores, :rank, :integer
    add_column :squad_scores, :order, :integer

    safety_assured do # Column has just been created, so it's empty and fast to index
      add_index :city_scores, :rank
      add_index :insanity_scores, :rank
      add_index :solo_scores, :rank
      add_index :squad_scores, :rank
    end
  end
end
