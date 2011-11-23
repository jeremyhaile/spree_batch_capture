class SpreeBatchProcess::Worker::Bogus < SpreeBatchProcess::Worker::Base
  
  def self.run(batch_process)
    return true
  end

  def self.options_description(batch)
    {:options => batch.options.to_s}
  end

  def self.errors_description(batch)
    {:bogus_errors => []}
  end

end
