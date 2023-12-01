# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    return true if Time.now.utc > Aoc.release_time(request.params[:day]) + 48.hours

    request.env["warden"]&.user&.solved?(request.params[:day], request.params[:challenge])
  end
end
