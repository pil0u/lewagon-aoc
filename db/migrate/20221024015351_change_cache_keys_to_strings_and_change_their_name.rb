# frozen_string_literal: true

class ChangeCacheKeysToStringsAndChangeTheirName < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      change_column :solo_points, :cache_key, :string
      change_column :solo_scores, :cache_key, :string
      change_column :squad_points, :cache_key, :string
      change_column :squad_scores, :cache_key, :string

      rename_column :solo_points, :cache_key, :cache_fingerprint
      rename_column :solo_scores, :cache_key, :cache_fingerprint
      rename_column :squad_points, :cache_key, :cache_fingerprint
      rename_column :squad_scores, :cache_key, :cache_fingerprint
    end
  end

  def down
    safety_assured do
      # datatype change cannot be rolled back

      rename_column :solo_points, :cache_fingerprint, :cache_key
      rename_column :solo_scores, :cache_fingerprint, :cache_key
      rename_column :squad_points, :cache_fingerprint, :cache_key
      rename_column :squad_scores, :cache_fingerprint, :cache_key
    end
  end
end
