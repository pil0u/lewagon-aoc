class MakeCacheKeyMoreObviousInCacheModels < ActiveRecord::Migration[7.0]
  def change
    safety_assured { # No data in tables when this will be run + only cache tables
      rename_column :solo_points, :fetched_at, :cache_key
      rename_column :solo_scores, :fetched_at, :cache_key
    }
  end
end
