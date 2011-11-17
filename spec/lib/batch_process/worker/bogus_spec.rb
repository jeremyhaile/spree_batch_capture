require 'spec_helper'

describe BatchProcess::Worker::Bogus do

  it "should return true when run" do
    BatchProcess::Worker::Bogus.run("bogus").should be_true
  end

end
