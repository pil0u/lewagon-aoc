# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action :set_snippet, only: %i[edit update]

  def show
    @day = params[:day]
    @challenge = params[:challenge]
    @language = params[:language]

    @snippet = Snippets::Builder.call(language: current_user.favourite_language)

    base_snippets = Snippet.includes(:user, :reactions).where(day: @day, challenge: @challenge)
    @languages = base_snippets.pluck(:language).uniq.sort

    snippets_scope = @language.present? ? base_snippets.where(language: @language) : base_snippets

    @snippets = snippets_scope.sort_by do |snippet|
      total_reactions = snippet.reactions.size
      learning_reactions = snippet.reactions.count { |r| r.reaction_type == "learning" }
      hours_since_publish = (Time.current - snippet.created_at) / 1.hour

      (1 + learning_reactions) * (1 + total_reactions) / ((1 + hours_since_publish)**1.8)
    end.reverse

    @text_area_placeholder = <<~TEXT
      Paste in your code directly here. Most common languages are supported.

      Markdown is supported: you can write an entire guide about your approach.
      In that case, pick the language featured in your guide.
    TEXT
  end

  def edit; end

  def create
    @snippet = Snippets::Builder.call(
      code: snippet_params[:code],
      language: snippet_params[:language],
      user: current_user,
      day: params[:day],
      challenge: params[:challenge]
    )

    if @snippet.save
      post_slack_message
      redirect_to snippet_path(day: params[:day], challenge: params[:challenge]), notice: "Your solution was published"
    else
      redirect_to snippet_path(day: params[:day], challenge: params[:challenge]), alert: @snippet.errors.full_messages
    end
  end

  def update
    if @snippet.update(snippet_params)
      redirect_to snippet_path(day: @snippet.day, challenge: @snippet.challenge), notice: "Your solution was edited"
    else
      redirect_to snippet_path(day: @snippet.day, challenge: @snippet.challenge), alert: @snippet.errors.full_messages
    end
  end

  private

  def set_snippet
    @snippet = current_user.snippets.find(params[:id])
  end

  def post_slack_message
    client = Slack::Web::Client.new
    puzzle = Puzzle.by_date(Aoc.begin_time.change(day: params[:day]))
    username = "<#{helpers.profile_url(current_user.uid)}|#{current_user.username}>"
    solution = "<#{helpers.snippet_url(day: @snippet.day, challenge: @snippet.challenge, anchor: @snippet.id)}|solution>"
    text = "#{username} submitted a new #{solution} for part #{params[:challenge]} in :#{@snippet.language}-hd:"
    client.chat_postMessage(channel: ENV.fetch("SLACK_CHANNEL", "#aoc-dev"), text:, thread_ts: puzzle.thread_ts)
  end

  def snippet_params
    params.require(:snippet).permit(:code, :language)
  end
end
