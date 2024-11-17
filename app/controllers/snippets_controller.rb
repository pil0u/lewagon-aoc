# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action :set_snippet, only: %i[edit update]

  def show
    @day = params[:day]
    @challenge = params[:challenge]
    @language = params[:language]

    @snippet = Snippets::Builder.call(language: current_user.favourite_language)
    @snippets = Snippet.includes(:user, :reactions).where(day: @day, challenge: @challenge).order(created_at: :desc)

    @languages = @snippets.pluck(:language).uniq.sort
    @snippets = @snippets.where(language: @language) if @language

    @text_area_placeholder = <<~TEXT
      This box is super smart.
      Paste your code directly here, it will work.
      Write a super nice guide in Markdown, it will work too.
      If your Markdown tutorial features Python code, choose Python as a language.
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

  def discuss
    @snippet = Snippet.find(params[:id])
    return redirect_to @snippet.slack_url if @snippet.slack_url

    text = "`SOLUTION` Hey <@#{@snippet.user.slack_id}>, some people want to discuss your :#{@snippet.language}-hd: #{solution_markdown} on puzzle #{@snippet.day} part #{@snippet.challenge}"
    message = client.chat_postMessage(channel: ENV.fetch("SLACK_CHANNEL", "#aoc-dev"), text:)
    slack_thread = client.chat_getPermalink(channel: message["channel"], message_ts: message["message"]["ts"])
    @snippet.update(slack_url: slack_thread[:permalink])

    redirect_to @snippet.slack_url
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def post_slack_message
    puzzle = Puzzle.by_date(Aoc.begin_time.change(day: params[:day]))
    username = "<#{helpers.profile_url(current_user.uid)}|#{current_user.username}>"
    text = "#{username} submitted a new #{solution_markdown} for part #{params[:challenge]} in :#{@snippet.language}-hd:"
    client.chat_postMessage(channel: ENV.fetch("SLACK_CHANNEL", "#aoc-dev"), text:, thread_ts: puzzle.thread_ts)
  end

  def set_snippet
    @snippet = current_user.snippets.find(params[:id])
  end

  def solution_markdown
    "<#{helpers.snippet_url(day: @snippet.day, challenge: @snippet.challenge, anchor: @snippet.id)}|solution>"
  end

  def snippet_params
    params.require(:snippet).permit(:code, :language)
  end
end
