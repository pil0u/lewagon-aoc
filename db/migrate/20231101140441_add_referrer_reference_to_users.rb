# frozen_string_literal: true

class AddReferrerReferenceToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :users, :referrer, index: { algorithm: :concurrently }
  end
end
