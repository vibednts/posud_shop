module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: %i[edit update destroy]

    def index
      @categories = Category.includes(:products).order(:name)
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "Категорію додано"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Зміни збережено"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.destroy
        redirect_to admin_categories_path, notice: "Категорію видалено"
      else
        redirect_to admin_categories_path, alert: "Не можна видалити категорію, у якій є товари"
      end
    end

    private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :slug, :description)
      end
  end
end
