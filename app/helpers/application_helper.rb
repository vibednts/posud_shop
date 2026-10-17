module ApplicationHelper
  def format_price(value)
    number_to_currency(value, unit: "₴", format: "%n %u", delimiter: " ", precision: 0)
  end
end
