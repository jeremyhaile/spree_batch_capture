Order.class_eval do

  def self.capturable(options={})
    options = {
      :failed => :include
    }.merge(options)

    case options[:failed]
    when :only then statuses = ['failed']
    when :exclude then statuses = ['pending']
    when :include then statuses = ['pending', 'failed']
    else 
      statuses = ['pending']
    end

    o = Order.where("state = 'complete' AND payment_state IN (?)", statuses)

    o = o.where("completed_at >= ?", options[:start_time]) if options[:start_time]
    o = o.where("completed_at <= ?", options[:end_time]) if options[:end_time]

    return o
  end

end

