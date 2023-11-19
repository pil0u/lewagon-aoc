# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    return true if DateTime.current > Aoc.begin_time.change(day: request.params[:day] + 1)

    request.env["warden"]&.user&.solved?(request.params[:day], request.params[:challenge])
  end
end
