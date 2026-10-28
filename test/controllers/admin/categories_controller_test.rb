require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:admin) }

  test "список категорій" do
    get admin_categories_path
    assert_response :success
    assert_includes response.body, categories(:full).name
  end

  test "додавання категорії" do
    assert_difference("Category.count", 1) do
      post admin_categories_path, params: { category: { name: "Мийні засоби", slug: "detergents" } }
    end
    assert_redirected_to admin_categories_path
  end

  test "неправильний slug не зберігається" do
    assert_no_difference("Category.count") do
      post admin_categories_path, params: { category: { name: "Мийні засоби", slug: "мийні засоби" } }
    end
    assert_response :unprocessable_entity
  end

  test "перейменування категорії" do
    patch admin_category_path(categories(:empty)), params: { category: { name: "Аксесуари та засоби" } }
    assert_equal "Аксесуари та засоби", categories(:empty).reload.name
  end

  test "категорію з товарами видалити не можна" do
    assert_no_difference("Category.count") { delete admin_category_path(categories(:full)) }
    assert_match "Не можна видалити", flash[:alert]
  end

  test "порожня категорія видаляється" do
    assert_difference("Category.count", -1) { delete admin_category_path(categories(:empty)) }
  end
end
