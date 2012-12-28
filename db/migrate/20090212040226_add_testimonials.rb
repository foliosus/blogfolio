class AddTestimonials < ActiveRecord::Migration
  def self.up
    add_column :clients, :testimonial_author, :string, :limit => 60
    add_column :clients, :testimonial_text, :text
  end

  def self.down
    remove_column :clients, :testimonial_text
    remove_column :clients, :testimonial_author
  end
end
