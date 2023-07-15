# frozen_string_literal: true

class DropViews < ActiveRecord::Migration[7.0]
  def up
    safety_assured { drop_all_views }
  end

  def down
    create_view :completion_ranks,    version: 2, materialized: true
    create_view :point_values,        version: 1, materialized: true
    create_view :scores,              version: 1, materialized: true
    create_view :ranks,               version: 2, materialized: true
    create_view :batch_contributions, version: 1, materialized: true
    create_view :city_contributions,  version: 1, materialized: true
    create_view :batch_points,        version: 2, materialized: true
    create_view :batch_scores,        version: 2, materialized: true

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
  end
end
