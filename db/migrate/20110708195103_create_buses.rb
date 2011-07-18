class CreateBuses < ActiveRecord::Migration
  def self.up
    create_table :buses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :buses
  end
end
