require 'resque'
class BatchProcess::BackgroundRunner

  def self.perform(batch)

    # only supports Resque right now, but theoretically another background runner abstraction can be added.

    klass = batch.worker_klass

    if klass.respond_to?(:perform)
      Resque.enqueue(klass, batch.id)
    else
      raise BatchProcess::Error::InvalidWorker.new "Worker class must respond to 'perform'."
    end
    return true
  end

end
