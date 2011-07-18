class CreateDlnas < ActiveRecord::Migration
  def self.up
    create_table :dlnas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :dlnas
  end
end
