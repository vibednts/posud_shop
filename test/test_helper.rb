ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Тести запускаються паралельно на всіх ядрах процесора
    parallelize(workers: :number_of_processors)

    # Завантажуємо всі фікстури з test/fixtures/*.yml
    fixtures :all
  end
end

module ActionDispatch
  class IntegrationTest
    # sign_in / sign_out від Devise для тестів контролерів
    include Devise::Test::IntegrationHelpers
  end
end
