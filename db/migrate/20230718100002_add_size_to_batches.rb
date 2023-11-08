# frozen_string_literal: true

class AddSizeToBatches < ActiveRecord::Migration[7.0]
  def change
    add_column :batches, :size, :integer
  end
end
