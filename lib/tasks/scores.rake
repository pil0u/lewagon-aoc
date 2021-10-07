# frozen_string_literal: true

require "aoc"
require "scores"

namespace :scores do
  desc "Fetch completition timestamps from AoC API and upsert them in scores table"
  task fetch: :environment do
    room_ids = ENV["AOC_ROOMS"].split(",")

    # TODO: Add some logic to handle multiple rooms

    room_id = room_ids.first.split("-").first
    object = Aoc.fetch_json(room_id)

    User.update_sync_status_from(object)

    # pp object
    # byebug

    # TODO: Upsert timestamps
  end
end
