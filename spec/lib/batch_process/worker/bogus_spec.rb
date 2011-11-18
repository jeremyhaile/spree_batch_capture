require 'spec_helper'

describe SpreeBatchProcess::Worker::Bogus do

  it "should return true when run" do
    SpreeBatchProcess::Worker::Bogus.run("bogus").should be_true
  end

end
