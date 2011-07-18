class CreateKerberos < ActiveRecord::Migration
  def self.up
    create_table :kerberos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :kerberos
  end
end
