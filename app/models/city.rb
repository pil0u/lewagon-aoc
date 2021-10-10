# frozen_string_literal: true

class City < ApplicationRecord
  has_many :city_scores, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, uniqueness: true

  def self.agg_insert_query
    <<-SQL.squish
      with

      _ranked_by_city as (
        select
          c.id as city_id,
          s.day,
          s.challenge,
          s.user_id,
          s.completion_unix_time,
          dense_rank() over (partition by c.id, s.day, s.challenge order by s.completion_unix_time) as _rank
        from scores s
        left join users u
        on s.user_id = u.id
        left join cities c
        on u.city_id = c.id
        where c.id is not null
        order by city_id, day, challenge
      )

      insert into city_scores (city_id, day, challenge, user_id, completion_unix_time, updated_at)
      select city_id, day, challenge, user_id, completion_unix_time, current_timestamp
      from _ranked_by_city
      where _rank = 1
    SQL
  end
end
