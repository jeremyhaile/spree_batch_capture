require 'spec_helper'

describe Batch do

  before do
    @bogus_batch = Factory(:batch)
  end

  describe "when created" do
    subject { @bogus_batch }
    its(:state) { should eql 'queued' }
    its(:started_at) { should be_nil }
    its(:completed_at) { should be_nil }
  end

  describe "when running a batch" do
    it "should call run_batch! when transitioning to running" do
      @bogus_batch.should_receive(:run_batch!).and_return(true)
      @bogus_batch.run!
      @bogus_batch.should be_running
      @bogus_batch.started_at.should_not be_nil
    end

    it "should run immediately" do
      @bogus_batch.should_receive(:run_in_background).and_return(false)
      SpreeBatchProcess::Worker::Bogus.should_receive(:perform).with(@bogus_batch).and_return(true)

      @bogus_batch.run_batch!
    end

    describe "that completes successfully" do
      before { @bogus_batch.run! }

      subject { @bogus_batch }
      its(:state) { should eql 'completed' }
      its(:started_at) { should_not be_nil }
      its(:completed_at) { should_not be_nil }

    end

    it "should run in the background" do
      @bogus_batch.should_receive(:run_in_background).and_return(true)
      SpreeBatchProcess::BackgroundRunner.should_receive(:perform).and_return(true)
      @bogus_batch.run_batch!
    end

  end

  describe "when getting the class" do
    subject { @bogus_batch.worker_klass }
    it { should eql SpreeBatchProcess::Worker::Bogus }

    it "should raise a InvalidBatch error if the batch is invalid" do
      @bogus_batch.worker_class = "invalid"
      
      expect { @bogus_batch.worker_klass }.
        to raise_error(SpreeBatchProcess::Error::InvalidBatch)

    end
    
  end

end
