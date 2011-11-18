# Batch factories

Factory.define :batch do |b|
  b.worker_class "Bogus"
  b.run_in_background false
  b.after_create do |batch|
    batch.options = { :test => true }
  end
end

Factory.define :running_batch, :parent => :batch do |b|
  b.state "running"
  b.started_at Time.now
end
