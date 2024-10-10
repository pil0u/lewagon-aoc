# frozen_string_literal: true

class AddThreadTsToPuzzles < ActiveRecord::Migration[7.1]
  def change
    add_column :puzzles, :thread_ts, :string
  end
end
