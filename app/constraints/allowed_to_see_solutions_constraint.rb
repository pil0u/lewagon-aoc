# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    return true if Time.now.utc > Aoc.begin_time.change(day: request.params[:day].to_i + 2)

    request.env["warden"]&.user&.solved?(request.params[:day], request.params[:challenge])
  end
end
