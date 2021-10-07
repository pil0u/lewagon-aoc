# frozen_string_literal: true

class RemoveSlotsFieldsStates < ActiveRecord::Migration[6.1]
  def change
    remove_column :states, :slots_room_1, :integer
    remove_column :states, :slots_room_2, :integer
  end
end
