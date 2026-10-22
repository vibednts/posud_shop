class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @brands = Product.distinct.order(:brand).pluck(:brand)
    @category = Category.find_by(slug: params[:category])

    scope = Product.includes(:category).with_attached_image
    scope = scope.where(category: @category) if @category
    scope = scope.where(brand: params[:brand]) if params[:brand].present?
    scope = scope.where(width_cm: params[:width]) if params[:width].present?
    scope = scope.where(installation: params[:installation]) if Product.installations.key?(params[:installation])
    scope = scope.where("price >= ?", params[:min_price]) if params[:min_price].present?
    scope = scope.where("price <= ?", params[:max_price]) if params[:max_price].present?
    if params[:q].present?
      scope = scope.where("name LIKE ?", "%#{Product.sanitize_sql_like(params[:q])}%")
    end

    scope = case params[:sort]
            when "price_asc"  then scope.order(price: :asc)
            when "price_desc" then scope.order(price: :desc)
            else scope.order(:id)
            end

    @products = scope
  end

  def show
    @product = Product.find(params[:id])
  end
end
