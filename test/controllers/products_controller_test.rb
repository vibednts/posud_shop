require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "каталог показує всі товари" do
    get products_path
    assert_response :success
    assert_select "h1", "Каталог посудомийних машин"
    [ products(:bosch), products(:beko), products(:sold_out) ].each do |p|
      assert_includes response.body, p.name
    end
  end

  test "фільтр за категорією" do
    get products_path(category: "slim")
    assert_response :success
    assert_select "h1", categories(:slim).name
    assert_includes response.body, products(:beko).name
    assert_not_includes response.body, products(:bosch).name
  end

  test "фільтр за брендом і шириною" do
    get products_path(brand: "Bosch", width: 60)
    assert_includes response.body, products(:bosch).name
    assert_not_includes response.body, products(:beko).name
  end

  test "фільтр за діапазоном цін" do
    get products_path(min_price: 13_000, max_price: 15_000)
    assert_includes response.body, products(:sold_out).name
    assert_not_includes response.body, products(:bosch).name
    assert_not_includes response.body, products(:beko).name
  end

  test "пошук за назвою" do
    get products_path(q: "beko")
    assert_includes response.body, products(:beko).name
    assert_not_includes response.body, products(:bosch).name
  end

  test "сортування за ціною" do
    get products_path(sort: "price_asc")
    assert_operator response.body.index(products(:beko).name), :<, response.body.index(products(:bosch).name)

    get products_path(sort: "price_desc")
    assert_operator response.body.index(products(:bosch).name), :<, response.body.index(products(:beko).name)
  end

  test "сторінка товару з характеристиками і відгуками" do
    get product_path(products(:beko))
    assert_response :success
    assert_select "h1", products(:beko).name
    assert_includes response.body, reviews(:customer_on_beko).body
  end

  test "неіснуючий товар — сторінка 404" do
    get product_path(id: 999_999)
    assert_response :not_found
    assert_select "h1", "Сторінку не знайдено"
  end
end
