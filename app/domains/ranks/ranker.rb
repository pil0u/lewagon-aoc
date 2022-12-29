# frozen_string_literal: true

module Ranks
  class Ranker
    def self.rank_and_number(input)
      new(input.dup).number
    end

    def initialize(scores)
      @scores = scores
    end

    def number(collection = rank)
      gap = 0
      prev = {}

      collection.each_with_index.map do |score, index|
        if score[:score] == prev[:score]
          gap += 1
        else
          gap = 0
        end

        rank = index + 1 - gap
        prev = score

        score.merge(rank:, order: index)
      end
    end

    def rank
      @scores.sort_by { |score| ranking_criterion(score) }.reverse
    end

    def ranking_criterion(*)
      raise NotImplementedError
    end
  end
end
