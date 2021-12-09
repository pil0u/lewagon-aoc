# frozen_string_literal: true

module Stats
  class BatchesController < ApplicationController
    before_action :set_batch, only: [:show]

    def show
      @batch_mates = @batch.users
                           .left_joins(:city).joins(:score, :rank).preload(:score, :rank, :city)
                           .order("ranks.in_batch")
    end

    private

    def set_batch
      @batch = Batch.find_by!(number: params[:number])
    end
  end
end
