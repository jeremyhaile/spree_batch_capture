Factory.define :completed_order, :parent => :order_with_totals do |o|
  o.state 'confirm'

  o.after_create do |order|
    address = Factory :address
    order.ship_address = address
    order.bill_address = address

    payment = Factory.create(:payment, {
      :amount => order.item_total,
      :order => order,
      :payment_method => Factory(:bogus_payment_method, {:environment => Rails.env}),
    })

    # Advance to completed.
    order.next
    # make sure everything is up to date
    order.reload
  end

end
