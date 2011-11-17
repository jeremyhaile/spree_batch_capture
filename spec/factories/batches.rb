# Batch factories

Factory.define :batch do |b|
  b.worker_class "Bogus"
  b.options Hash.new(:test => true) 
  b.run_in_background false
end

Factory.define :running_batch, :parent => :batch do |b|
  b.state "running"
  b.started_at Time.now
end
