require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "фікстура категорії валідна" do
    assert categories(:full).valid?
  end

  test "назва та slug обов'язкові й унікальні" do
    category = Category.new(name: categories(:full).name, slug: "full")
    assert_not category.valid?
    assert category.errors.key?(:name)
    assert category.errors.key?(:slug)
  end

  test "slug лише латиницею, цифрами та дефісом" do
    category = Category.new(name: "Нова", slug: "Нова категорія")
    assert_not category.valid?
    category.slug = "new-category-2"
    assert category.valid?
  end

  test "категорію з товарами видалити не можна" do
    assert_not categories(:full).destroy
    assert Category.exists?(categories(:full).id)
  end

  test "порожню категорію можна видалити" do
    assert_difference("Category.count", -1) { categories(:empty).destroy }
  end
end
