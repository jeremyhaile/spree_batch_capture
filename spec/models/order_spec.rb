require 'spec_helper'

describe Order do
  describe "capturable scope", :focus do
    before do
      user = User.anonymous!
      defaults = {
        :state => 'complete',
        :completed_at => 5.days.ago,
        :payment_state => 'pending',
        :user => user
      }

      Order.delete_all

      # default order
      @default_order = Factory(:order, defaults)

      # failed payment order
      @failed_order = Factory(:order, defaults.merge({:payment_state => 'failed', :completed_at => 8.days.ago}))

      # incomplete order
      @incomplete_order = Factory(:order, {
        :user => user, 
        :payment_state => nil, 
        :state => 'cart', 
        :completed_at => nil
      })
    end

    it "should return pending and failed by default" do
      orders = Order.capturable
      orders.should include @default_order
      orders.should include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should only return pending if failed option is set to exclude" do
      orders = Order.capturable :failed => :exclude
      orders.should include @default_order
      orders.should_not include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should only return failed if failed option is set to only" do
      orders = Order.capturable :failed => :only 
      orders.should_not include @default_order
      orders.should include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should return valid orders when a start date is specified" do
      orders = Order.capturable :start_time => 6.days.ago
      orders.should include @default_order
      orders.should_not include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should return valid orders when an end date is specified" do
      orders = Order.capturable :end_time => 6.days.ago
      orders.should_not include @default_order
      orders.should include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should not return valid orders when no orders are in the range." do
      orders = Order.capturable :start_time => 11.days.ago, :end_time => 10.days.ago
      orders.should_not include @default_order
      orders.should_not include @failed_order
      orders.should_not include @incomplete_order
    end

    it "should return an ActiveRelation" do
      orders = Order.capturable :start_time => 10.days.ago
      orders.should be_kind_of ActiveRecord::Relation
    end

  end
  
end
