module SpreeBatchProcess
  class Worker::Base
    
    # Actual method called by the Batch Process.
    # takes a SpreeBatchProcess object or an id
    # This method cleans up any params and allows a consistent interface
    # for the worker's run method.
    def self.perform(batch)
      bp = batch.kind_of?(Batch) ? batch : ::Batch.find_by_id(batch)

      if ! bp || ! bp.kind_of?(Batch)
        raise Error::InvalidBatch.new "Invalid batch record."
      end

      if bp.running?

        run_result = run(bp)
        if run_result
          bp.complete!
        else
          bp.fail!
        end
        
      else
        # mark the batch as failed
        bp.fail!

        # raise an exception so that it can be handled downstream and
        # not hide any bugs. The perform method should not be receiving 
        # batches that are not in the running state.
        raise Error::InvalidBatch.new "Expected the batch state to be running, got '#{bp.state}' instead." 
      end

      return run_result
    end


    # Implemented by subclasses
    def self.run(batch_process)
      return true
    end


    
  end
end
