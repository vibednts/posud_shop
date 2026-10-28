require "test_helper"

# Доступ до адмін-панелі
class Admin::AccessTest < ActionDispatch::IntegrationTest
  test "гостя відправляє на вхід" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "звичайний користувач бачить 404, ніби адмінки не існує" do
    sign_in users(:customer)
    get admin_root_path
    assert_response :not_found
    get admin_products_path
    assert_response :not_found
  end

  test "адміністратор бачить панель керування зі статистикою" do
    sign_in users(:admin)
    get admin_root_path
    assert_response :success
    assert_select "h1", "Панель керування"
  end
end
