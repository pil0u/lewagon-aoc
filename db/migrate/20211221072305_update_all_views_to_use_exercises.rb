# frozen_string_literal: true

class UpdateAllViewsToUseExercises < ActiveRecord::Migration[6.1]
  # Since views are dependent from one another they have to be replaced in-place or all dropped and recreated
  # but since they are MATERIALIZED VIEWs we cannot do in-place replacement, so we have to drop them all.
  def up
    # Drop-cascade the root of the old architecture
    drop_all_views(:completion_ranks)

    create_function :max_allowed_contributors_in_batch, version: 1
    create_function :max_allowed_contributors_in_city, version: 1

    create_view :exercises,           version: 1, materialized: true
    create_view :completion_ranks,    version: 3, materialized: true
    create_view :point_values,        version: 2, materialized: true

    create_view :user_points,         version: 1, materialized: true
    create_view :scores,              version: 2, materialized: true

    create_view :batch_contributions, version: 2, materialized: true
    create_view :city_contributions,  version: 2, materialized: true

    create_view :batch_points,        version: 3, materialized: true
    create_view :batch_scores,        version: 3, materialized: true
    create_view :city_points,         version: 3, materialized: true
    create_view :city_scores,         version: 3, materialized: true

    add_index :completion_ranks,    %i[user_id day challenge],  unique: true
    add_index :point_values,        %i[user_id day challenge],  unique: true
    add_index :point_values,        :in_contest
    add_index :point_values,        :in_city
    add_index :point_values,        :in_batch

    add_index :user_points,         %i[user_id day challenge],  unique: true
    add_index :user_points,         :city_id
    add_index :user_points,         :batch_id
    add_index :user_points,         :rank_in_contest
    add_index :user_points,         :rank_in_city
    add_index :user_points,         :rank_in_batch
    add_index :scores,              :rank_in_contest
    add_index :scores,              :rank_in_city
    add_index :scores,              :rank_in_batch

    add_index :batch_contributions, :participated
    add_index :batch_contributions, %i[user_id day challenge], unique: true
    add_index :city_contributions,  :participated
    add_index :city_contributions,  %i[user_id day challenge],  unique: true

    readd_common_indexes
  end

  # Reverting to last version
  def down
    # Drop-cascade the root of the new architecture
    drop_all_views(:exercises)

    drop_function :max_allowed_contributors_in_batch
    drop_function :max_allowed_contributors_in_city

    create_view :completion_ranks,    version: 2, materialized: true
    create_view :point_values,        version: 1, materialized: true
    create_view :scores,              version: 1, materialized: true
    create_view :ranks,               version: 2, materialized: true
    create_view :batch_contributions, version: 1, materialized: true
    create_view :city_contributions,  version: 1, materialized: true
    create_view :batch_points,        version: 2, materialized: true
    create_view :batch_scores,        version: 2, materialized: true
    create_view :city_points,         version: 2, materialized: true
    create_view :city_scores,         version: 2, materialized: true

    add_index :completion_ranks, :in_contest
    add_index :completion_ranks, :in_batch
    add_index :completion_ranks, :in_city
    add_index :ranks,            :user_id, unique: true

    readd_common_indexes
  end

  private

  def drop_all_views(root_view)
    # Dropping root with cascade to drop all views and their indexes
    execute "DROP MATERIALIZED VIEW #{quote_table_name(root_view)} CASCADE;"
  end

  def readd_common_indexes
    add_index :completion_ranks,    :completion_id,             unique: true
    add_index :point_values,        :completion_id,             unique: true
    add_index :scores,              :user_id,                   unique: true
    add_index :batch_contributions, :completion_id,             unique: true
    add_index :city_contributions,  :completion_id,             unique: true
    add_index :batch_points,        %i[batch_id day challenge], unique: true
    add_index :batch_scores,        :batch_id,                  unique: true
    add_index :city_points,         %i[city_id day challenge],  unique: true
    add_index :city_scores,         :city_id,                   unique: true
  end
end
