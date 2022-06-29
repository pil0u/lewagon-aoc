# frozen_string_literal: true

class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.datetime :last_api_fetch_start
      t.datetime :last_api_fetch_end
    end
  end
end
