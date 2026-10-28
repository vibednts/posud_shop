class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product

  def create
    review = @product.reviews.new(review_params.merge(user: current_user))

    if review.save
      redirect_to product_path(@product, anchor: "reviews"), notice: "Дякуємо за відгук!"
    else
      redirect_to product_path(@product, anchor: "reviews"), alert: review.errors.full_messages.to_sentence
    end
  end

  def destroy
    scope = current_user.admin? ? @product.reviews : @product.reviews.where(user: current_user)
    scope.find(params[:id]).destroy
    redirect_to product_path(@product, anchor: "reviews"), notice: "Відгук видалено"
  end

  private

    def set_product
      @product = Product.find(params[:product_id])
    end

    def review_params
      params.require(:review).permit(:rating, :body)
    end
end
