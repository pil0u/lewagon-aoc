# frozen_string_literal: true

class Score < ApplicationRecord
  belongs_to :user

  def self.replace_all(scores)
    if scores.any?
      Rails.logger.info "  Erasing all scores..."
      Score.delete_all

      Rails.logger.info "  Inserting new scores..."
      Score.insert_all(scores, unique_by: %i[user_id day challenge])
    else
      Rails.logger.info "Nothing to do!"
    end
  end

  def self.compute_ranks
    Rails.logger.info "  Computing ranks using fabulous SQL..."
    query = <<-SQL.squish

    with ranks as (
      select
        s.id as score_id,
        /* b.id as batch_id, */
        /* ci.id as city_id, */
        /* s.day, */
        /* s.challenge, */
        /* s.user_id, */
        /* s.completion_unix_time, */
        dense_rank() over (partition by s.day, s.challenge order by s.completion_unix_time) as rank_solo,
        dense_rank() over (partition by b.id, s.day, s.challenge order by s.completion_unix_time) as rank_in_batch,
        dense_rank() over (partition by ci.id, s.day, s.challenge order by s.completion_unix_time) as rank_in_city
      from scores s
      left join users u
      on s.user_id = u.id
      left join batches b
      on u.batch_id = b.id
      left join cities ci
      on u.city_id = ci.id
      /* order by day, challenge, rank_solo */
    )

    update scores
    set
      rank_solo = ranks.rank_solo,
      rank_in_batch = ranks.rank_in_batch,
      rank_in_city = ranks.rank_in_city,
      updated_at = current_timestamp
    from ranks
    where scores.id = ranks.score_id

    SQL

    ActiveRecord::Base.connection.exec_update(query, "compute_ranks")
  end
end
