require 'spec_helper'

describe Order do
  context "with a physical book" do
    let(:items) { [{type: 'print', price: 14.95, quantity: 1}] }
    let(:customer) { {address: ["1234 Main St.", "New York, NY 12345"]} }
    subject { Order.new(1, items, customer) }

    it "gets marked as charged" do
      subject.place_order(:stripe)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost

      expect(shipping_cost).to eq(5.99)
    end
  end

  context "as an ebook" do
    let(:items) { [{type: 'ebook', price: 14.95, quantity: 1}] }
    let(:customer) { {address: ["1234 Main St.", "New York, NY 12345"]} }
    subject { Order.new(1, items, customer) }

    it "gets marked as charged" do
      subject.place_order(:paypal)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost

      expect(shipping_cost).to eq(0)
    end
  end

  it "produces a text-based report" do
    items = [{type: 'ebook', price: 14.95, quantity: 5}]
    customer = {address: ["1234 Main St.", "New York, NY 12345"]}
    order = Order.new(12345, items, customer)
    report = "Order #12345\n" +
      "Ship to: 1234 Main St., New York, NY 12345\n" +
      "-----\n\n" +
      "Qty   | Item Name                       | Total\n" +
      "------|---------------------------------|------\n" +
      "5     | ebook                           | $74.75"

    expect(order.to_s).to eq(report)
  end

  context "a valid conference ticket order" do
    let(:items) { [{type: 'Conference Ticket', price: 300.00, quantity: 1}] }
    let(:customer) { {address: ["1234 Main St.", "New York, NY 12345"]} }
    subject { Order.new(1, items, customer) }

    it "gets marked as charged" do
      subject.place_order(:paypal)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost

      expect(shipping_cost).to eq(0)
    end

    it "produces a text-based report" do
      report = "Order #1\n" +
        "Ship to: 1234 Main St., New York, NY 12345\n" +
        "-----\n\n" +
        "Qty   | Item Name                       | Total\n" +
        "------|---------------------------------|------\n" +
        "1     | Conference Ticket               | $300.00"

      expect(subject.to_s).to eq(report)
    end
  end

  it "does not allow more than one conference ticket per order" do
    expect do
      Order.new(1337, [{type: 'Conference Ticket', price: 300.00, quantity: 3}], {address: ["456 Test St.", "New York, NY 12345"]})
    end.to raise_error("Conference tickets are limited to one per customer")
  end
end
