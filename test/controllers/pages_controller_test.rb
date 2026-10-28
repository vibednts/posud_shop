require "test_helper"

# Статичні сторінки: головна, доставка, гарантія, порадник, 404
class PagesControllerTest < ActionDispatch::IntegrationTest
  test "головна сторінка відкривається" do
    get root_path
    assert_response :success
    assert_select "h1", /Чистий посуд/
  end

  test "сторінка доставки показує всі способи доставки" do
    get delivery_path
    assert_response :success
    assert_select "h1", "Доставка й оплата"
    Order::DELIVERY_LABELS.each_value { |label| assert_includes response.body, ERB::Util.html_escape(label) }
  end

  test "сторінка гарантії відкривається" do
    get warranty_path
    assert_response :success
    assert_select "h1", "Гарантія"
  end

  test "порадник з вибору відкривається" do
    get guide_path
    assert_response :success
    assert_select "h1", "Як обрати посудомийну машину"
  end

  test "неіснуюча адреса повертає сторінку 404" do
    get "/such/page/does/not/exist"
    assert_response :not_found
    assert_select "h1", "Сторінку не знайдено"
  end
end
