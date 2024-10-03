# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    Completion.where(day: request.params[:day], challenge: request.params[:challenge])
              .count >= 5
  end
end
