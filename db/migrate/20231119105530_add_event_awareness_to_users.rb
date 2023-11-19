# frozen_string_literal: true

class AddEventAwarenessToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :event_awareness, :string
  end
end
