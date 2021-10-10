# frozen_string_literal: true

module Scores
  def self.insert(scores)
    if scores.any?
      Rails.logger.info "  Erasing all scores..."
      Score.delete_all

      Rails.logger.info "  Inserting new scores..."
      Score.insert_all(scores, unique_by: %i[user_id day challenge])
    else
      Rails.logger.info "Nothing to do!"
    end
  end

  def self.compute_for(table_name)
    Rails.logger.info "  Calculating scores for table '#{table_name}'..."

    # This is _not_ subject to SQL injections because table_name is always determined when method is called
    query = <<-SQL.squish
      with

      _compute as (
        select
          id,
          dense_rank() over (partition by day, challenge order by completion_unix_time desc) as score
        from #{table_name}
      )

      update #{table_name}
      set
        updated_at = current_timestamp,
        score = _compute.score
      from _compute
      where #{table_name}.id = _compute.id
    SQL

    ActiveRecord::Base.connection.exec_update(query, "compute_#{table_name}")
  end
end
