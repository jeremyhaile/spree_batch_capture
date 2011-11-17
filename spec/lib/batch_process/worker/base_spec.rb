require 'spec_helper'

describe BatchProcess::Worker::Base do

  
  describe "when running perform" do
    before do
      @bogus_batch = Factory(:running_batch)
    end

    it "should run the worker" do
      @bogus_batch.should_receive(:kind_of?)

      BatchProcess::Worker::Base.should_receive(:run).and_return(true)
      BatchProcess::Worker::Base.perform(@bogus_batch).should be_true
    end

    it "should mark the batch as completed when successful" do
      BatchProcess::Worker::Base.should_receive(:run).and_return(true)
      BatchProcess::Worker::Base.perform(@bogus_batch).should be_true

      @bogus_batch.state.should eql 'completed'

    end

    it "should mark the batch as failed when failed." do
      BatchProcess::Worker::Base.should_receive(:run).and_return(false)
      BatchProcess::Worker::Base.perform(@bogus_batch).should be_false

      @bogus_batch.state.should eql 'failed'

    end
    
  end

  describe "when handling errors" do
    before do
      @bogus_batch = Factory(:batch)
    end

    it "should raise an exception if the batch isn't running" do
      expect { BatchProcess::Worker::Base.perform(@bogus_batch) }.
        to raise_error(BatchProcess::Error::InvalidBatch)
      @bogus_batch.state.should eql 'failed'
    end

    it "should raise an exception if the batch isn't found" do
      expect { BatchProcess::Worker::Base.perform(99) }.
        to raise_error(BatchProcess::Error::InvalidBatch)
    end

    it "should raise an exception if the batch is completely invalid" do
      expect { BatchProcess::Worker::Base.perform("INVALID") }.
        to raise_error(BatchProcess::Error::InvalidBatch)
    end

  end


  
end
