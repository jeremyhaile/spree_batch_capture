class BatchProcess::Worker::Bogus < BatchProcess::Worker::Base
  
  def self.run(batch_process)
    return true
  end

end
