# frozen_string_literal: true

class Batch < ApplicationRecord
  has_many :batch_scores, dependent: :destroy
  has_many :users, dependent: :nullify

  def self.agg_insert_query
    <<-SQL.squish
      with

      _ranked_by_batch as (
        select
          b.id as batch_id,
          s.day,
          s.challenge,
          s.user_id,
          s.completion_unix_time,
          dense_rank() over (partition by b.id, s.day, s.challenge order by s.completion_unix_time) as _rank
        from scores s
        left join users u
        on s.user_id = u.id
        left join batches b
        on u.batch_id = b.id
        where b.id is not null
        order by batch_id, day, challenge
      )

      insert into batch_scores (batch_id, day, challenge, user_id, completion_unix_time, updated_at)
      select batch_id, day, challenge, user_id, completion_unix_time, current_timestamp
      from _ranked_by_batch
      where _rank = 1
    SQL
  end
end
