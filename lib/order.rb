VALID_PAYMENTS = [:cash, :cheque, :paypal, :stripe]

class Order
  def initialize(order_number, items, customer_info)
    @order_number = order_number
    @items = items
    @customer_info = customer_info
    @shipping_cost = calculate_shipping
    @order_total = 0
    @status = 'order placed'
    check_quantities
  end

  attr_reader :status, :shipping_cost

  def place_order(payment_type)
    @items.each do |item|
      @order_total += item[:price]*item[:quantity]
    end
    @order_total += @shipping_cost

    charge(payment_type)
  end

  def charge(payment_type)
    if payment_valid?(payment_type)
      send_email_receipt
      @status = 'charged'
    else
      send_payment_failure_email
      @status = 'failed'
    end

    def ship
      @items.each do |item|
        if item[:type] == 'ebook'
          # [send email with download link...]
        elsif item[:type] == 'ticket'
          # [print ticket]
        end
        # [print shipping label]
      end

      @status = 'shipped'
    end
  end

  def to_s
    output = "Order ##{@order_number}\n" +
      "Ship to: #{@customer_info[:address].join(", ")}\n" +
      "-----\n\n" +
      "Qty   | Item Name                       | Total\n" +
      "------|---------------------------------|------\n"
    @items.each do |item|
      output += "#{item[:quantity]}     | #{item[:type]}" + " "*(32-item[:type].length) + "| $#{line_total(item)}"
    end
    output
  end

  private

  def check_quantities
    @items.each do |item|
      if item[:type] == 'Conference Ticket' && item[:quantity] > 1
        raise 'Conference tickets are limited to one per customer'
      end
    end
  end

  def calculate_shipping
    total = 0
    @items.each do |item|
      total += 5.99 if item[:type] == "print"
    end
    total
  end

  def payment_valid?(payment_type)
    (payment_type == :paypal && charge_paypal_account(@order_total)) ||
      (payment_type == :stripe && charge_credit_card(@order_total)) || VALID_PAYMENTS.include?(payment_type)
  end


  def send_email_receipt
    # [send email receipt]
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_paypal_account(amount)
    true
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_credit_card(amount)
    true
  end

  def line_total(item)
    '%.2f' % (item[:quantity] * item[:price]+calculate_shipping)
  end

end