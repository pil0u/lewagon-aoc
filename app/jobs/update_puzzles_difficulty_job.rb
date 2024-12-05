# frozen_string_literal: true

class UpdatePuzzlesDifficultyJob < ApplicationJob
  queue_as :default

  def perform
    puzzles = Puzzle.where(is_difficulty_final: false)

    if puzzles.empty?
      Rails.logger.info "✔ No puzzle difficulty to update"
      return
    end

    client = Slack::Web::Client.new
    channel = "C064BH3TLGJ"

    puzzles.each do |puzzle|
      day = puzzle.date.day
      url = URI("https://aoc-difficulty.ew.r.appspot.com/score?year=#{puzzle.date.year}&day=#{day}")

      Rails.logger.info "\tUpdating difficulty for day #{day}..."
      response = Net::HTTP.get_response(url)

      if response.code != "200" || response.body.include?("error")
        text = "⚠️ <@URZ0F4TEF> Error updating difficulty for day #{day} (#{response.code})"
        message = client.chat_postMessage(channel:, text:)
        client.chat_postMessage(channel:, thread_ts: message["message"]["ts"], text: "#{url}\n```#{response.body}```")
        next
      end

      data = JSON.parse(response.body)

      puzzle.update(
        difficulty_part_1: data["1"]["quartile"],
        difficulty_part_2: data["2"]["quartile"],
        is_difficulty_final: data["1"]["final"] && data["2"]["final"]
      )

      next unless puzzle.is_difficulty_final

      part_1 = Puzzle::DIFFICULTY_LEVELS[puzzle.difficulty_part_1]
      part_2 = Puzzle::DIFFICULTY_LEVELS[puzzle.difficulty_part_2]

      text = <<~TEXT
        Estimated difficulty for day #{day} (experimental feature):
        - part 1 is *`#{part_1[:difficulty]}`* #{part_1[:colour]}
        - part 2 is *`#{part_2[:difficulty]}`* #{part_2[:colour]}
      TEXT

      client.chat_postMessage(channel: ENV.fetch("SLACK_CHANNEL", "C064BH3TLGJ"), text:)
    end

    Rails.logger.info "✔ Puzzle difficulties updated"
  end
end
