module SpreeBatchProcess
  class Worker::Capture < Worker::Base
    # setting a default queue for Resque
    @queue = :batch_capture

    def self.run(batch)
      options = {
        # capturable is a hash of values that will be passed to the Order.capturable method
        :capturable => {},
      }
      options.merge!(batch.options) if batch.options

      batch_errors = []
      begin
        capturable_orders = Order.capturable(options[:capturable])

        capturable_orders.each do |order|
          order.payments.each do |payment|
            payment_source = payment.source
            if payment_source.can_capture? payment
              begin
                payment_source.capture(payment)
              rescue => e
                batch_errors << "Error capturing payment for order #{order.number}. #{e.class} :: #{e.message}"
                payment.fail
              end

            else
              batch_errors << "Order #{order.number} is not eligible for capture with payment #{payment.source_type} for #{payment.amount}."
            end
          end
        end

      rescue => e
        batch_errors << "There was a fatal error running the batch. #{e.class} :: #{e.message}"
      end

      batch.options[:batch_errors] = batch_errors
      batch.save!

      return batch_errors.empty?
    end

    # see the worker base for description of this method
    def self.options_description(batch)
      opts = {}
      return opts unless batch.options && batch.options[:capturable]

      if batch.options[:capturable][:failed]
        opts[:include_failed_items] = batch.options[:capturable][:failed]
      else
        opts[:include_failed_items] = :include
      end

      if batch.options[:capturable][:start_time] 
        opts[:orders_completed_after] = batch.options[:capturable][:start_time]
      end

      if batch.options[:capturable][:end_time] 
        opts[:orders_completed_before] = batch.options[:capturable][:end_time]
      end
      
      return opts
    end

    # see the worker base for description of this method
    def self.errors_description(batch)
      errors = batch.options.nil? ? [] : batch.options[:batch_errors]
      { :errors_during_capture => errors || [] }
    end
    
  end
end
