# frozen_string_literal: true

class CreateBatchPointsView < ActiveRecord::Migration[6.1]
  def change
    create_view :batch_points, materialized: true
    add_index :batch_points, %i[batch_id day challenge], unique: true
  end
end
