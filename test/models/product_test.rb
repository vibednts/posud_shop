require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup { @product = products(:bosch) }

  test "фікстура товару валідна" do
    assert @product.valid?
  end

  test "назва та бренд обов'язкові" do
    @product.name = ""
    @product.brand = ""
    assert_not @product.valid?
    assert @product.errors.key?(:name)
    assert @product.errors.key?(:brand)
  end

  test "ціна має бути більшою за нуль" do
    @product.price = 0
    assert_not @product.valid?
    assert @product.errors.key?(:price)
  end

  test "залишок не може бути від'ємним" do
    @product.stock = -1
    assert_not @product.valid?
    assert @product.errors.key?(:stock)
  end

  test "ширина лише 45 або 60 см" do
    @product.width_cm = 50
    assert_not @product.valid?
    @product.width_cm = 45
    assert @product.valid?
  end

  test "клас енергоспоживання з переліку A–G" do
    @product.energy_class = "Z"
    assert_not @product.valid?
    assert @product.errors.key?(:energy_class)
  end

  test "рівень шуму в межах 30–70 дБ" do
    @product.noise_db = 90
    assert_not @product.valid?
    @product.noise_db = 30
    assert @product.valid?
  end

  test "невідомий тип встановлення не проходить валідацію" do
    @product.installation = "on_ceiling"
    assert_not @product.valid?
    assert @product.errors.key?(:installation)
  end

  test "in_stock? залежить від залишку" do
    assert products(:bosch).in_stock?
    assert_not products(:sold_out).in_stock?
  end

  test "to_param містить id та назву для гарних URL" do
    assert_equal "#{@product.id}-bosch-smv25ex00k", @product.to_param
  end

  test "середній рейтинг і кількість відгуків" do
    beko = products(:beko)
    assert_equal 4.5, beko.average_rating
    assert_equal 2, beko.reviews_count
    assert_nil @product.average_rating
  end

  test "зображення лише JPG, PNG або WebP" do
    @product.image.attach(io: StringIO.new("not an image"), filename: "notes.txt", content_type: "text/plain")
    assert_not @product.valid?
    assert @product.errors.key?(:image)
  end

  test "не можна видалити товар, який є в замовленнях" do
    assert_no_difference("Product.count") { @product.destroy }
    assert @product.errors.any?
  end
end
