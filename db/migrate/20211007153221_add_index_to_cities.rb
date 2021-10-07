# frozen_string_literal: true

class AddIndexToCities < ActiveRecord::Migration[6.1]
  def change
    add_index :cities, :name, unique: true
  end
end
