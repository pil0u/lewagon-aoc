# frozen_string_literal: true

class AddVanityNameToCities < ActiveRecord::Migration[7.1]
  def change
    add_column :cities, :vanity_name, :string
  end
end
