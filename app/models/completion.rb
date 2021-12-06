# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user
  has_one :point_value # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_one :completion_rank # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_one :city_contribution # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_one :batch_contribution # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view

  scope :actual, -> { where.not(completion_unix_time: nil) }

  def self.replace_all(completions)
    Rails.logger.info "  Erasing all completions..."
    Completion.delete_all

    if completions.any?
      Rails.logger.info "  Inserting new completions..."
      Completion.insert_all(completions, unique_by: %i[user_id day challenge])
    else
      Rails.logger.info "  No completions to insert!"
    end
    Help.refresh_views!
  end

  def self.compute_ranks
    Rails.logger.info "  Computing ranks using fabulous SQL..."
    query = <<-SQL.squish

    with ranks as (
      select
        s.id as completion_id,
        /* b.id as batch_id, */
        /* ci.id as city_id, */
        /* s.day, */
        /* s.challenge, */
        /* s.user_id, */
        /* s.completion_unix_time, */
        dense_rank() over (partition by s.day, s.challenge order by s.completion_unix_time) as rank_solo,
        dense_rank() over (partition by b.id, s.day, s.challenge order by s.completion_unix_time) as rank_in_batch,
        dense_rank() over (partition by ci.id, s.day, s.challenge order by s.completion_unix_time) as rank_in_city
      from completions s
      left join users u
      on s.user_id = u.id
      left join batches b
      on u.batch_id = b.id
      left join cities ci
      on u.city_id = ci.id
      /* order by day, challenge, rank_solo */
    )

    update completions
    set
      rank_solo = ranks.rank_solo,
      rank_in_batch = ranks.rank_in_batch,
      rank_in_city = ranks.rank_in_city,
      updated_at = current_timestamp
    from ranks
    where completions.id = ranks.completion_id

    SQL

    ActiveRecord::Base.connection.exec_update(query, "compute_ranks")
  end
end
