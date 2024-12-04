# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action :set_snippet, only: %i[edit update]

  def show
    @day = params[:day]
    @challenge = params[:challenge]
    @language = params[:language]

    @snippet = Snippets::Builder.call(language: current_user.favourite_language)

    reaction_relations = Reaction::TYPES.map { |type| :"#{type}_reactions" }
    base_snippets = Snippet.includes(:user, :reactions, *reaction_relations).where(day: @day, challenge: @challenge)
    @languages = base_snippets.pluck(:language).uniq.sort

    snippets_scope = @language.present? ? base_snippets.where(language: @language) : base_snippets

    @snippets = snippets_scope.sort_by do |snippet|
      total_reactions = snippet.reactions.size
      learning_reactions = snippet.learning_reactions.size
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
      update_slack_thread
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
    return redirect_to @snippet.slack_url if @snippet.slack_url.present?

    solution_markdown = "<#{helpers.snippet_url(day: @snippet.day, challenge: @snippet.challenge, anchor: @snippet.id)}|solution>"
    text = "`SOLUTION` Hey <@#{@snippet.user.slack_id}>, some people want to discuss your :#{@snippet.language}-hd: #{solution_markdown} on puzzle #{@snippet.day} part #{@snippet.challenge}"
    message = client.chat_postMessage(channel: ENV.fetch("SLACK_CHANNEL", "C064BH3TLGJ"), text:)
    slack_thread = client.chat_getPermalink(channel: message["channel"], message_ts: message["message"]["ts"])
    @snippet.update(slack_url: slack_thread[:permalink])

    redirect_to @snippet.slack_url
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def update_slack_thread
    puzzle = Puzzle.by_date(Aoc.begin_time.change(day: params[:day]))
    return if puzzle.thread_ts.nil?

    snippets = Snippet.includes(:user).where(day: @snippet.day)
    part_one, part_two = snippets.partition { |snippet| snippet.challenge == 1 }.map do |solutions|
      solutions.map { |snippet| solution_markdown(snippet, "#{snippet.user.username} :#{snippet.language}-hd:") }
    end

    text = "#{puzzle.title}\n\nSolutions for part 1: #{part_one.join(', ')}\nSolutions for part 2: #{part_two.join(', ')}"
    client.chat_update(channel: ENV.fetch("SLACK_CHANNEL", "C064BH3TLGJ"), text:, ts: puzzle.thread_ts)
  end

  def set_snippet
    @snippet = current_user.snippets.find(params[:id])
  end

  def solution_markdown(snippet = @snippet, text = "solution")
    "<#{helpers.snippet_url(day: snippet.day, challenge: snippet.challenge, anchor: snippet.id)}|#{text}>"
  end

  def snippet_params
    params.require(:snippet).permit(:code, :language)
  end
end
