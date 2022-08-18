# frozen_string_literal: true

class AddEnteredHardcoreToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :entered_hardcore, :boolean, default: false
  end
end
