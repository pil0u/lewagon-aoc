# frozen_string_literal: true

class AddForeignKeyOnBatches < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :batches, :cities, validate: false
  end
end
