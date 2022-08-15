# frozen_string_literal: true

class AddSizeToCity < ActiveRecord::Migration[7.0]
  def change
    add_column :cities, :size, :integer
  end
end
