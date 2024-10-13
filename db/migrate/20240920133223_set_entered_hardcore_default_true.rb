# frozen_string_literal: true

class SetEnteredHardcoreDefaultTrue < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :entered_hardcore, from: false, to: true
  end
end
