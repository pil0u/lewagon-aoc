# frozen_string_literal: true

class AddReferenceToBatches < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :batches, :city, index: { algorithm: :concurrently }
  end
end
