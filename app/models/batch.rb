class Batch < ActiveRecord::Base

  serialize :options, Hash

  scope :queued, where(:state => 'queued')
  
  state_machine :initial => 'queued' do
    
    event :run do
      transition :from => 'queued', :to => "running"
    end

    event :complete do
      transition :from => 'running', :to => "completed"
    end

    event :fail do
      transition all => 'failed'
    end

    event :cancel do 
      transition :from => "queued", :to => "canceled"
    end

    event :resume do
      transition :from => "canceled", :to => "queued"
    end

    event :retry do
      transition :from => "failed", :to => "queued"
    end

    before_transition :to => 'queued' do |b|
      b.started_at = nil
      b.completed_at = nil
    end

    before_transition :to => ['failed', 'canceled', 'completed'] do |b|
      b.completed_at = Time.now
    end 

    before_transition :to => 'running' do |b|
      b.started_at = Time.now 
    end

    after_transition :to => "running", :do => :run_batch!

  end


  def run_batch!
    if self.run_in_background
      BatchProcess::BackgroundRunner.perform(self)
    else
      worker_klass.perform(self)
    end
    
  end

  def worker_klass
    BatchProcess::Worker.const_get(self.worker_class)
  end


end
