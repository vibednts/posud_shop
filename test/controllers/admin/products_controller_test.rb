require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  PRODUCT = {
    name: "Siemens SN63HX42VE", brand: "Siemens", price: 32_999, stock: 3, width_cm: 60,
    installation: "built_in", capacity_sets: 14, energy_class: "C", noise_db: 42,
    programs_count: 8, warranty_months: 36, description: "Тиха вбудована модель"
  }.freeze

  setup { sign_in users(:admin) }

  test "список товарів і пошук" do
    get admin_products_path(q: "Beko")
    assert_response :success
    assert_includes response.body, products(:beko).name
    assert_not_includes response.body, products(:bosch).name
  end

  test "додавання товару" do
    assert_difference("Product.count", 1) do
      post admin_products_path, params: { product: PRODUCT.merge(category_id: categories(:full).id) }
    end
    assert_redirected_to admin_products_path
  end

  test "додавання товару з зображенням" do
    image = fixture_file_upload("dishwasher.png", "image/png")
    post admin_products_path, params: { product: PRODUCT.merge(category_id: categories(:full).id, image: image) }
    assert Product.find_by(name: PRODUCT[:name]).image.attached?
  end

  test "невалідний товар не зберігається" do
    assert_no_difference("Product.count") do
      post admin_products_path, params: { product: PRODUCT.merge(price: 0, category_id: categories(:full).id) }
    end
    assert_response :unprocessable_entity
  end

  test "редагування товару" do
    patch admin_product_path(products(:beko)), params: { product: { price: 11_999, stock: 7 } }
    assert_redirected_to admin_products_path
    assert_equal 11_999, products(:beko).reload.price
    assert_equal 7, products(:beko).stock
  end

  test "товар без замовлень видаляється" do
    assert_difference("Product.count", -1) { delete admin_product_path(products(:sold_out)) }
  end

  test "товар із замовлень не видаляється" do
    assert_no_difference("Product.count") { delete admin_product_path(products(:bosch)) }
    assert_match "Не можна видалити", flash[:alert]
  end
end
