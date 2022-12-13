class AddCompletionIdsToSoloPointsAndInsanityPoints < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :solo_points, :completion, index: { algorithm: :concurrently }
    add_reference :insanity_points, :completion, index: { algorithm: :concurrently }
  end
end
