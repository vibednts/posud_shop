module ApplicationHelper
def rating_stars(value)
  full = value.to_f.round.clamp(0, 5)
  ("★" * full) + ("☆" * (5 - full))
end
  def format_price(value)
    number_to_currency(value, unit: "₴", format: "%n %u", delimiter: " ", precision: 0)
  end
end
