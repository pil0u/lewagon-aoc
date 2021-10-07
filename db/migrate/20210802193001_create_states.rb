# frozen_string_literal: true

class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states do |t|
      t.datetime :last_api_check_start
      t.datetime :last_api_check_end
      t.integer :slots_room_1
      t.integer :slots_room_2

      t.timestamps
    end
  end
end
