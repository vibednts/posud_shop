class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart, :cart_count
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
 # Кошик поточного відвідувача (створюється, коли потрібен)
  def current_cart
    @current_cart ||=
      if user_signed_in?
        Cart.find_or_create_by!(user: current_user)
      else
        Cart.find_by(id: session[:cart_id], user_id: nil) ||
          Cart.create!.tap { |c| session[:cart_id] = c.id }
      end
  end

  # Лічильник для шапки: нічого не створює в БД
  def cart_count
    cart = if user_signed_in?
             Cart.find_by(user: current_user)
           else
             Cart.find_by(id: session[:cart_id], user_id: nil)
           end
    cart ? cart.total_quantity : 0
  end

  # Після входу зливаємо гостьовий кошик з акаунтним
  def after_sign_in_path_for(resource)
    merge_guest_cart(resource)
    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name phone])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name phone])
  end

 private

  def merge_guest_cart(user)
    guest = Cart.find_by(id: session[:cart_id], user_id: nil)
    return unless guest

  def render_not_found
  render "errors/not_found", status: :not_found, formats: :html
end

    user_cart = Cart.find_or_create_by!(user: user)
    guest.cart_items.includes(:product).each do |item|
      user_cart.add_product(item.product, item.quantity)
    end
    guest.destroy
    session.delete(:cart_id)
  end

end
