# frozen_string_literal: true

class UpdateAllRanksInViews < ActiveRecord::Migration[6.1]
  # Since views are dependent from one another they have to be replaced in-place or all dropped and recreated
  # but since they are MATERIALIZED VIEWs we cannot do in-place replacement, so we have to drop them all.
  def up
    drop_all_views

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

    readd_indexes
  end

  # Reverting to 1st version
  def down
    drop_all_views

    create_view :completion_ranks,    version: 1, materialized: true
    create_view :point_values,        version: 1, materialized: true
    create_view :scores,              version: 1, materialized: true
    create_view :ranks,               version: 1, materialized: true
    create_view :batch_contributions, version: 1, materialized: true
    create_view :city_contributions,  version: 1, materialized: true
    create_view :batch_points,        version: 1, materialized: true
    create_view :batch_scores,        version: 1, materialized: true
    create_view :city_points,         version: 1, materialized: true
    create_view :city_scores,         version: 1, materialized: true

    readd_indexes
  end

  private

  def drop_all_views
    # Root of the whole view architecture
    execute "DROP MATERIALIZED VIEW #{quote_table_name(:completion_ranks)} CASCADE;"
  end

  def readd_indexes
    add_index :completion_ranks,    :completion_id, unique: true
    add_index :completion_ranks,    :in_contest
    add_index :completion_ranks,    :in_batch
    add_index :completion_ranks,    :in_city
    add_index :point_values,        :completion_id,             unique: true
    add_index :scores,              :user_id,                   unique: true
    add_index :ranks,               :user_id,                   unique: true
    add_index :batch_contributions, :completion_id,             unique: true
    add_index :city_contributions,  :completion_id,             unique: true
    add_index :batch_points,        %i[batch_id day challenge], unique: true
    add_index :batch_scores,        :batch_id,                  unique: true
    add_index :city_points,         %i[city_id day challenge],  unique: true
    add_index :city_scores,         :city_id,                   unique: true
  end
end
