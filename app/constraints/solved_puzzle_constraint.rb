# frozen_string_literal: true

class SolvedPuzzleConstraint
  def matches?(request)
    request.env["warden"].user.solved?(request.params[:day], request.params[:challenge])
  end
end
