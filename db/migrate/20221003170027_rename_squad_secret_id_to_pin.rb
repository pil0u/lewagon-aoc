class RenameSquadSecretIdToPin < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :squads, :secret_id, :pin }
  end
end
