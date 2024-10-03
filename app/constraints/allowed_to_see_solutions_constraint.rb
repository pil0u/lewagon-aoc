# frozen_string_literal: true

class AllowedToSeeSolutionsConstraint
  def matches?(request)
    @day = request.params[:day]
    @challenge = request.params[:challenge]
    @user = request.env["warden"]&.user

    solved_by_current_user? || solved_by_five_users?
  end

  private

  def solved_by_current_user?
    @user&.solved?(@day, @challenge)
  end

  def solved_by_five_users?
    Completion.where(day: @day, challenge: @challenge).count >= 5
  end
end
