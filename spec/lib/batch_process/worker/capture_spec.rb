require 'spec_helper'

module SpreeBatchProcess
  describe Worker::Capture do

    
    describe "when capturing a set of orders payments" do
      
      before do
        @order1 = Factory(:completed_order)
        @order2 = Factory(:completed_order)
        @batch = Factory(:batch)
      end

      it "should accept a list of orders and mark them as captured." do

        Worker::Capture.run(@batch).should be_true

        @order1.reload
        assert_equal(@order1.payment_total, @order1.total, "Order 1 totals.")
        assert_equal(@order1.payment_state, "paid", "Order 1 payment state.")
        assert_equal(@order1.payment.state, "completed", "Order 1 payments state.")

        @order2.reload
        assert_equal(@order2.payment_total, @order2.total, "Order 2 totals.")
        assert_equal(@order2.payment_state, "paid", "Order 2 payment state.")
        assert_equal(@order2.payment.state, "completed", "Order 2 payments state.")
        

      end

      it "should accept a list of orders with multiple payments and capture each one." do
        @order1.payment.amount = 5
        @order1.payments << Factory(:payment, {
          :amount => 5, 
          :state => 'pending', 
          :payment_method => Factory(:bogus_payment_method, {:environment => Rails.env}),
        })

        Worker::Capture.run(@batch).should be_true

        @order1.reload
        assert_equal(@order1.payment_total, 10, "Order 1 totals.")
        assert_equal(@order1.payment_state, "paid", "Order 1 payment state.")
        assert_equal(@order1.payments.first.state, "completed", "Order 1 first payments state.")
        assert_equal(@order1.payments.last.state, "completed", "Order 1 last payments state.")

      end

    end

    describe "when handling errors" do
      before do 
        @order = Factory(:completed_order)
        @batch = Factory(:batch)
      end

      it "should add an error message when the payment isn't capturable" do
        @order.payment.void
        Worker::Capture.run(@batch).should be_false

        @batch.options[:batch_errors].size.should eql 1
        @batch.options[:batch_errors].first.should include "not eligible for capture"
      end

      it "should add an error message when an exception is raised." do
        Order.should_receive(:capturable).and_return("invalid")
        Worker::Capture.run(@batch).should be_false

        @batch.options[:batch_errors].size.should eql 1
        @batch.options[:batch_errors].first.should include "fatal error running the batch"
      end

      it "should add an error message when an error occurs during capture." do
        pm = @order.payment.payment_method
        pm.environment = 'this should break'
        pm.save!
        @order.reload

        Worker::Capture.run(@batch).should be_false

        @batch.options[:batch_errors].size.should eql 1
        @batch.options[:batch_errors].first.should include "Error capturing payment"

      end

    end
    
  end
end
