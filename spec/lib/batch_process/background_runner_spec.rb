require 'spec_helper'

describe BatchProcess::BackgroundRunner do
  before do
    @batch = Factory(:batch)
  end

  it "should enqueue the batch" do
    Resque.should_receive(:enqueue).with(BatchProcess::Worker::Bogus, @batch.id).and_return(true)
    BatchProcess::BackgroundRunner.perform(@batch).should be_true
  end

  it "should raise an InvalidWorker exception if the worker doesn't respond to perform" do
    BatchProcess::Worker::Bogus.should_receive(:respond_to?).with(:perform).and_return(false)
    expect { BatchProcess::BackgroundRunner.perform(@batch) }.
      to raise_error(BatchProcess::Error::InvalidWorker)
  end


  
end
