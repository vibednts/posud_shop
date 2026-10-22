# Демонстраційна імітація платіжного шлюзу. Реальні гроші не списуються,
# дані картки не зберігаються.
class FakePayment
  Result = Struct.new(:success, :error, :last4, keyword_init: true) do
    def success? = success
  end

  def initialize(number:, holder:, expiry:, cvv:)
    @number = number.to_s.gsub(/[\s-]/, "")
    @holder = holder.to_s.strip
    @expiry = expiry.to_s.strip
    @cvv    = cvv.to_s.strip
  end

  def call
    return failure("Номер картки має містити 16 цифр") unless @number.match?(/\A\d{16}\z/)
    return failure("Невірний номер картки") unless luhn_valid?
    return failure("Вкажіть ім'я власника латиницею, як на картці") unless @holder.match?(/\A[A-Za-z][A-Za-z .'-]{2,}\z/)
    return failure("Термін дії вкажіть у форматі ММ/РР") unless @expiry.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z})
    return failure("Термін дії картки минув") if expired?
    return failure("CVV має містити 3 цифри") unless @cvv.match?(/\A\d{3}\z/)
    return failure("Банк відхилив платіж: недостатньо коштів") if @number.end_with?("0002")

    Result.new(success: true, last4: @number[-4..])
  end

  private

  def failure(message)
    Result.new(success: false, error: message)
  end

  def luhn_valid?
    sum = @number.reverse.chars.each_with_index.sum do |ch, i|
      d = ch.to_i
      d *= 2 if i.odd?
      d -= 9 if d > 9
      d
    end
    (sum % 10).zero?
  end

  def expired?
    month, year = @expiry.split("/").map(&:to_i)
    Date.new(2000 + year, month, 1).end_of_month < Date.current
  end
end
