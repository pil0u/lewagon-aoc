# frozen_string_literal: true

class CreateBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :batches do |t|
      t.integer :number

      t.timestamps
    end
  end
end
