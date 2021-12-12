# frozen_string_literal: true

module Stats
  class BatchesController < ApplicationController
    before_action :set_batch, only: [:show]

    def show
      @batch_mates = @batch.users
                           .left_joins(:city).joins(:batch_contributions, :score)
                           .preload(:score, :city, :batch_contributions)
                           .order("rank_in_batch").uniq
    end

    private

    def set_batch
      @batch = Batch.find_by!(number: params[:number])
    end
  end
end
