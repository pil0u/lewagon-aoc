# frozen_string_literal: true

require "open-uri"

class GenerateSlackThread < ApplicationJob
  queue_as :default

  retry_on SlackError do |_, error|
    client.chat_postMessage(channel: "#aoc-dev", text: error)
  end

  def perform(date)
    @puzzle = Puzzle.fins_or_create_by(date:)
    return if @puzzle.slack_url.present?

    if @puzzle.persisted?
      @puzzle.title = scraped_title || "`SPOILER` <#{@puzzle.url}|Day #{date.day}>"
      @puzzle.thread_ts = message["message"]["ts"]
      @puzzle.slack_url = permalink
      @puzzle.save!
    else
      client.chat_postMessage(channel: "#aoc-dev", text: @puzzle.errors.full_messages.join(", "))
    end
  end

  private

  def channel
    ENV.fetch("SLACK_CHANNEL", "#aoc-dev")
  end

  def client
    @client ||= Slack::Web::Client.new
  end

  def message
    @message ||= if @puzzle.thread_ts.present?
                   { "message" => { "ts" => @puzzle.thread_ts } }
                 else
                   response = client.chat_postMessage(channel:, text: @puzzle.title)
                   raise SlackError.new, "Failed to post message for day ##{@puzzle.date.day}" unless response["ok"]

                   response
                 end
  end

  def permalink
    @permalink ||= begin
      response = client.chat_getPermalink(channel:, message_ts: message["message"]["ts"])[:permalink]
      raise SlackError.new, "Failed to get permalink for day ##{@puzzle.date.day}" unless response["ok"]

      response
    end
  end

  def scraped_title
    @scraped_title ||= begin
      html = URI.parse(@puzzle.url).open
      doc = Nokogiri::HTML(html)
      titles = doc.css("h2").map(&:text)
      raw_title = titles.find { |title| title.match?(/--- Day \d+:/) }

      "`SPOILER` <#{@puzzle.url}|#{raw_title.gsub('---', '').strip}>" if raw_title.present?
    rescue OpenURI::HTTPError
      day = @puzzle.date.day
      client.chat_postMessage(
        channel: "#aoc-dev",
        text: "Title not found for day ##{day}, run `bundle exec rake 'update_puzzle_thread[#{day},#{channel}]'`"
      )

      nil
    end
  end
end
