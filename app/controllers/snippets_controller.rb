# frozen_string_literal: true

class SnippetsController < ApplicationController
  def show
    @day = params[:day]
    @challenge = params[:challenge]

    @snippet = Snippets::Builder.call(language: current_user.favourite_language)
    @snippets = Snippet.includes(:user, :reactions).where(day: @day, challenge: @challenge).order(created_at: :desc)

    @text_area_placeholder = <<~TEXT
      This box is super smart.
      Paste your code directly here, it will work.
      Write a super nice guide in Markdown, it will work too.
      If your Markdown tutorial features Python code, choose Python as a language.
    TEXT
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
