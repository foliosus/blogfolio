class Email < ActiveRecord::Base
  self.abstract_class = true
  
  attr_accessor :from
  attr_accessor :subject
  attr_accessor :body
  
  validates_presence_of     [:from, :subject, :body]
  validates_length_of       :from,    :within => 6..100 #r@a.wk
  validates_format_of       :from,    :with => Authentication.email_regex, :message => Authentication.bad_email_message, :unless => Proc.new {|email| email.from == DEFAULT_EMAIL}
  
  DEFAULT_EMAIL = 'Oregon Montessori Association <info@oregonmontessori.org>'
  
  class << self
    def columns()
      @columns ||= []
    end
    
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      reset_column_information
    end
    
    # Do not reset @columns
    def reset_column_information
      read_methods.each { |name| undef_method(name) }
      @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil
    end
  end
end
