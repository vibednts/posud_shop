class ErrorsController < ApplicationController
  def not_found
    render status: :not_found, formats: :html
  end
end
