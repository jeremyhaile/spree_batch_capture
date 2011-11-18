require 'spec_helper'

module SpreeBatchProcess
  describe BackgroundRunner do
    before do
      @batch = Factory(:batch)
    end

    it "should enqueue the batch" do
      Resque.should_receive(:enqueue).with(Worker::Bogus, @batch.id).and_return(true)
      BackgroundRunner.perform(@batch).should be_true
    end

    it "should raise an InvalidWorker exception if the worker doesn't respond to perform" do
      Worker::Bogus.should_receive(:respond_to?).with(:perform).and_return(false)
      expect { BackgroundRunner.perform(@batch) }.
        to raise_error(Error::InvalidWorker)
    end
    
  end
end
