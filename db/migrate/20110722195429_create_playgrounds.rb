class CreatePlaygrounds < ActiveRecord::Migration
  def self.up
    create_table :playgrounds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :playgrounds
  end
end
