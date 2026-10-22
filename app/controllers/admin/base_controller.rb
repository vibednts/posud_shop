module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    private

    # Для не-адмінів сторінки наче не існує
    def require_admin
      render_not_found unless current_user.admin?
    end
  end
end
