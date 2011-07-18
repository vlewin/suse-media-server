class CreateSambas < ActiveRecord::Migration
  def self.up
    create_table :sambas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :sambas
  end
end
