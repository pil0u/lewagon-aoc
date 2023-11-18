# frozen_string_literal: true

class AddFavouriteLanguageToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :favourite_language, :string
  end
end
