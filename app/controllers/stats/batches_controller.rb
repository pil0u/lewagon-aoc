# frozen_string_literal: true

module Stats
  class BatchesController < ApplicationController
    before_action :set_batch, only: [:show]

    def show
      @batch_mates = @batch.users
                           .left_joins(:city).joins(:score, :rank).preload(:score, :rank, :city)
                           .order("ranks.in_batch")

      contributors_per_challenge = Completion.actual.left_joins(user: :batch).where("batch_id = ?", @batch.id).group(:day, :challenge).count.to_h
      @daily_contributors = contributors_per_challenge.group_by { |key, _l| key.first }.transform_values { |contributors_counts| contributors_counts.map(&:last) }

      @latest_day = Aoc.in_progress? ? Time.now.getlocal("-05:00").day : 25

      @max_contributors = Batch.max_contributors
    end

    private

    def set_batch
      @batch = Batch.find_by!(number: params[:number])
    end
  end
end
