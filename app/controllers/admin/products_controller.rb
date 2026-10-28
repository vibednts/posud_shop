module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update destroy]

    def index
      @products = Product.includes(:category).with_attached_image.order(:id)
      if params[:q].present?
        like = "%#{Product.sanitize_sql_like(params[:q])}%"
        @products = @products.where("name LIKE ? OR brand LIKE ?", like, like)
      end
    end

    def new
      @product = Product.new(width_cm: 60, installation: "built_in", energy_class: "E",
                             warranty_months: 24, stock: 0)
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Товар додано"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        @product.image.purge if params[:remove_image] == "1" && product_params[:image].blank?
        redirect_to admin_products_path, notice: "Зміни збережено"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: "Товар видалено"
      else
        redirect_to admin_products_path,
                    alert: "Не можна видалити товар, який є в замовленнях. Поставте залишок 0."
      end
    end

    private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :brand, :description, :price, :stock, :width_cm,
                                        :installation, :capacity_sets, :energy_class, :noise_db,
                                        :programs_count, :warranty_months, :category_id, :image)
      end
  end
end
