class SpreeBatchProcess::Worker::Bogus < SpreeBatchProcess::Worker::Base
  
  def self.run(batch_process)
    return true
  end

end
