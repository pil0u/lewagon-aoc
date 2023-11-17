# frozen_string_literal: true

class AddPrivateLeaderboardToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :private_leaderboard, :string
  end
end
