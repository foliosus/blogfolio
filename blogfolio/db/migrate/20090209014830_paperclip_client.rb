class PaperclipClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :screenshot_file_name, :string, :limit => 40
    add_column :clients, :screenshot_content_type, :string, :limit => 40
    add_column :clients, :screenshot_file_size, :integer
    add_column :clients, :screenshot_updated_at, :datetime
  end

  def self.down
    remove_column :clients, :screenshot_file_name
    remove_column :clients, :screenshot_content_type
    remove_column :clients, :screenshot_file_size
    remove_column :clients, :screenshot_updated_at
  end
end
