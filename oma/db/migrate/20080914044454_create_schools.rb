class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string      :name, :limit => 60, :null => false
      t.string      :phone, :limit => 10
      t.string      :email, :limit => 60
      t.string      :url, :limit => 60
      t.string      :address, :limit => 60, :null => false
      t.string      :address2, :limit => 60
      t.string      :city, :limit => 25, :null => false
      t.string      :state, :limit => 2, :null => false, :default => 'OR'
      t.string      :zip, :limit => 5, :null => false
      t.boolean     :contact_by_email, :null => false, :default => true
      t.boolean     :volunteer, :null => false, :default => false
      t.boolean     :speaker, :null => false, :default => false
      t.integer     :infants, :default => 0
      t.integer     :primary, :default => 0
      t.integer     :lower_elementary, :default => 0
      t.integer     :upper_elementary, :default => 0
      t.integer     :high_school, :default => 0
      t.timestamps
    end
    
    add_column :memberships, :member_type, :string, :null => false
    add_column :members, :school_id, :integer
  end

  def self.down
    remove_column :memberships, :member_type
    remove_column :members, :school_id
    
    drop_table :schools
  end
end
