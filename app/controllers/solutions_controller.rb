class SolutionsController < ApplicationController
  def show
    @day = params[:day]
    @challenge = params[:challenge]

    @snippet = Snippet.new
    @snippets = Snippet.includes(:user).order(created_at: :desc)
  end

  def create
    snippet = Snippet.new(
      code: helpers.sanitize(solution_params[:code]),
      language: solution_params[:language],
      user: current_user,
      day: params[:day],
      challenge: params[:challenge]
    )

    if snippet.save
      redirect_to solution_path(day: params[:day], challenge: params[:challenge]), notice: "Your solution was published"
    else
      redirect_to solution_path(day: params[:day], challenge: params[:challenge]), alert: snippet.errors.full_messages[0].to_s
    end
  end

  private

  def solution_params
    params.require(:snippet).permit(:code, :language)
  end
end
