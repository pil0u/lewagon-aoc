# frozen_string_literal: true

module Help
  def self.median(array)
    return if array.empty?

    sorted = array.sort
    l = array.length

    (0.5 * (sorted[(l - 1) / 2] + sorted[l / 2])).ceil
  end

  def self.refresh_views!
    Score.refresh
    CityScore.refresh
    BatchScore.refresh
  end
end
