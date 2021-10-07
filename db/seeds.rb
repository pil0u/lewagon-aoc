# frozen_string_literal: true

# Initialize cities

cities = [
  "Amsterdam",
  "Bali",
  "Barcelona",
  "Belo Horizonte",
  "Berlin",
  "Bordeaux",
  "Brussels",
  "Buenos Aires",
  "Casablanca",
  "Cologne",
  "Dubai",
  "Istanbul",
  "Lausanne",
  "Lille",
  "Lima",
  "Lisbon",
  "London",
  "Lyon",
  "Madrid",
  "Marseille",
  "Mauritius",
  "Melbourne",
  "Mexico",
  "Milan",
  "Montreal",
  "Munich",
  "Nantes",
  "Nice",
  "Oslo",
  "Paris",
  "Rennes",
  "Rio de Janeiro",
  "Santiago",
  "Shanghai",
  "Shenzhen",
  "Singapore",
  "Stockholm",
  "São Paulo",
  "Tel Aviv",
  "Tokyo"
].map do |city|
  { name: city }
end

City.create!(cities)
Rails.logger.info "Cities seeded ✔️"
