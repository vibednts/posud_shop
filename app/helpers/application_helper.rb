module ApplicationHelper
  def rating_stars(value)
    full = value.to_f.round.clamp(0, 5)
    ("★" * full) + ("☆" * (5 - full))
  end

  def product_picture(product)
    if product.image.attached?
      image_tag product.image, alt: product.name, loading: "lazy"
    else
      content_tag(:span, product.brand, class: "no-photo")
    end
  end

  def format_price(value)
    number_to_currency(value, unit: "₴", format: "%n %u", delimiter: " ", precision: 0)
  end
end
