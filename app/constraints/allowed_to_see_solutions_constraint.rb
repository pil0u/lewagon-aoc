# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    return true if Time.now.utc > Aoc.begin_time + (request.params[:day] + 1).days

    request.env["warden"]&.user&.solved?(request.params[:day], request.params[:challenge])
  end
end
