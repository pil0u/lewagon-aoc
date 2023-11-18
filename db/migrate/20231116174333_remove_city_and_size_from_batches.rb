# frozen_string_literal: true

class RemoveCityAndSizeFromBatches < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :batches, :city_id, :bigint }
    safety_assured { remove_column :batches, :size, :int }
  end
end
