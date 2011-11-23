module SpreeBatchProcess
  class Worker::Base
    
    # Actual method called by the Batch Process.
    # takes a SpreeBatchProcess object or an id
    # This method cleans up any params and allows a consistent interface
    # for the worker's run method.
    def self.perform(batch)
      bp = batch.kind_of?(Batch) ? batch : Batch.find_by_id(batch)

      if ! bp || ! bp.kind_of?(Batch)
        raise Error::InvalidBatch.new "Invalid batch record. Batch argument: '#{batch}' resulted in: '#{bp}'"
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

    # Used in the UI to display messages to the user
    # returns a hash where the keys are i18n keys for translation
    # that describe the "field" that is to be displayed, 
    # and the values are the values to be displayed.
    #
    # Override this is subclasses
    def self.options_description(batch)
      {}
    end

    # Used to display errors that occurred during the batch.
    # returns a hash with a single key value pair where the
    # key is an i18n translation key and the value is an 
    # array of strings
    #
    # Override this is subclasses
    def self.errors_description(batch)
      {:errors => []}
    end
    
    
  end
end
