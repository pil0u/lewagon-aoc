# frozen_string_literal: true

class ValidateForeignKeyOnBatches < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :batches, :cities
  end
end
