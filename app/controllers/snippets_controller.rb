# frozen_string_literal: true

class SnippetsController < ApplicationController
  def show
    @day = params[:day]
    @challenge = params[:challenge]

    @snippet = Snippets::Builder.call(language: current_user.favourite_language, code: "Paste here")
    @snippets = Snippet.includes(:user).where(day: @day, challenge: @challenge).order(created_at: :desc)
  end

  def create
    snippet = Snippets::Builder.call(
      code: snippet_params[:code],
      language: snippet_params[:language],
      user: current_user,
      day: params[:day],
      challenge: params[:challenge]
    )

    if snippet.save
      redirect_to snippet_path(day: params[:day], challenge: params[:challenge]), notice: "Your solution was published"
    else
      redirect_to snippet_path(day: params[:day], challenge: params[:challenge]), alert: snippet.errors.full_messages[0].to_s
    end
  end

  private

  def snippet_params
    params.require(:snippet).permit(:code, :language)
  end
end
