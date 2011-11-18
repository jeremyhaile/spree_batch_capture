require 'spec_helper'

module SpreeBatchProcess
  describe Worker::Base do

    
    describe "when running perform" do
      before do
        @bogus_batch = Factory(:running_batch)
      end

      it "should run the worker" do
        @bogus_batch.should_receive(:kind_of?)

        Worker::Base.should_receive(:run).and_return(true)
        Worker::Base.perform(@bogus_batch).should be_true
      end

      it "should mark the batch as completed when successful" do
        Worker::Base.should_receive(:run).and_return(true)
        Worker::Base.perform(@bogus_batch).should be_true

        @bogus_batch.state.should eql 'completed'

      end

      it "should mark the batch as failed when failed." do
        Worker::Base.should_receive(:run).and_return(false)
        Worker::Base.perform(@bogus_batch).should be_false

        @bogus_batch.state.should eql 'failed'

      end
      
    end

    describe "when handling errors" do
      before do
        @bogus_batch = Factory(:batch)
      end

      it "should raise an exception if the batch isn't running" do
        expect { Worker::Base.perform(@bogus_batch) }.
          to raise_error(Error::InvalidBatch)
        @bogus_batch.state.should eql 'failed'
      end

      it "should raise an exception if the batch isn't found" do
        expect { Worker::Base.perform(99) }.
          to raise_error(Error::InvalidBatch)
      end

      it "should raise an exception if the batch is completely invalid" do
        expect { Worker::Base.perform("INVALID") }.
          to raise_error(Error::InvalidBatch)
      end

    end


    
  end
end
