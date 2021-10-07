# Initialize cities

cities = %w[
  Amsterdam Bali Barcelona Belo\ Horizonte Berlin Bordeaux Brussels Buenos\ Aires Casablanca Cologne Dubai Istanbul Lausanne Lille Lima Lisbon London Lyon Madrid Marseille Mauritius Melbourne Mexico Milan Montreal Munich Nantes Nice Oslo Paris Rennes Rio\ de\ Janeiro Santiago Shanghai Shenzhen Singapore Stockholm São\ Paulo Tel\ Aviv Tokyo
].map { |city| { name: city } }

City.create!(cities)
