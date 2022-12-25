module Ranks
  class Ranker
    def self.rank(input)
      new(input.dup).rank!
    end

    def initialize(scores)
      @scores = scores
    end

    def rank!
      gaps = 0
      prev = nil
      ordered_scores = order

      ordered.each_with_index do |score, index|
        # if criterion(score) == criterion(prev)
        if score[:score] == prev[:score]
          gap += 1
        else
          gap = 0
        end

        rank = index + 1 - gap
        score[:rank] = rank

        prev = score
      end
      ordered
    end
  end
end
