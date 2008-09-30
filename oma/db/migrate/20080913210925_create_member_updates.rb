class CreateMemberUpdates < ActiveRecord::Migration
  def self.up
    create_table :member_updates do |t|
      t.string      :first_name, :limit => 40
      t.string      :last_name, :limit => 40
      t.string      :phone, :limit => 10
      t.string      :email, :limit => 60
      t.string      :address, :limit => 60
      t.string      :address2, :limit => 60
      t.string      :city, :limit => 25
      t.string      :state, :limit => 2
      t.string      :zip, :limit => 5
      t.boolean     :volunteer
      t.boolean     :speaker
      t.integer     :category_id
      t.integer     :member_id
      t.timestamps
    end
  end

  def self.down
    drop_table :member_updates
  end
end
