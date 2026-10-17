Product.destroy_all
Category.destroy_all

cats = {
  "full"     => Category.create!(name: "Повнорозмірні 60 см", slug: "full",     description: "Для великої родини"),
  "slim"     => Category.create!(name: "Вузькі 45 см",        slug: "slim",     description: "Для невеликої кухні"),
  "compact"  => Category.create!(name: "Компактні",           slug: "compact",  description: "Настільні моделі"),
  "accessory"=> Category.create!(name: "Аксесуари",           slug: "accessory", description: "Засоби та фільтри")
}

data = [
  ["Bosch SMV25EX00K",   "Bosch",      "full", 21999, 12, 60, :built_in,     13, "E", 48,  5, 24],
  ["Bosch SMS4HVI33E",   "Bosch",      "full", 26499,  8, 60, :freestanding, 14, "D", 42,  6, 24],
  ["Siemens SN63HX42VE", "Siemens",    "full", 32999,  5, 60, :built_in,     14, "C", 42,  8, 36],
  ["Electrolux ESF9516LOX", "Electrolux","slim", 17999, 10, 45, :freestanding, 9, "E", 49,  5, 24],
  ["Beko DIS25010",      "Beko",       "slim", 12499, 15, 45, :built_in,      10, "E", 49,  5, 24],
  ["Gorenje GS541D10W",  "Gorenje",    "slim", 14299,  0, 45, :freestanding,  9, "E", 47,  5, 24],
  ["Whirlpool WSC 3M17", "Whirlpool",  "compact", 11799, 7, 60, :freestanding, 6, "F", 51, 6, 24],
  ["Candy CDCP 6/E",     "Candy",      "compact",  9999, 9, 60, :freestanding, 6, "F", 54, 6, 24]
]

data.each do |name, brand, cat, price, stock, width, inst, sets, energy, noise, programs, warranty|
  Product.create!(
    name: name, brand: brand, category: cats[cat], price: price, stock: stock,
    width_cm: width, installation: inst, capacity_sets: sets, energy_class: energy,
    noise_db: noise, programs_count: programs, warranty_months: warranty,
    description: "#{brand} #{name}: надійна посудомийна машина з #{programs} програмами миття, " \
                 "місткістю #{sets} комплектів і рівнем шуму #{noise} дБ."
  )
end

puts "Створено: #{Category.count} категорій, #{Product.count} товарів"
