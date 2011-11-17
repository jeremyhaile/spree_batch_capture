class CreateBatch < ActiveRecord::Migration
  def self.up
    create_table :batches do |t|
      t.string :worker_class, :required => true
      t.string :state, :require => true, :default => "queued"
      t.text :options
      t.boolean :run_in_background, :required => true, :default => true
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :batches
  end
end
