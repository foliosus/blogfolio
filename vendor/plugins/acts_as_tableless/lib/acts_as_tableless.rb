# A tableless model behaves like an AR::Base model, but doesn't persist to the database
module ActsAsTableless
  def self.included(target)
    target.extend(ClassMethods)
  end

  module ClassMethods
    # Turn the ActiveRecord model that calls this into a table-less model.  It is an abstract class, and has columns defined by the passed in attributes.  This allows validations, associations and all of the other usual AR goodness, just without the ability to persist things to the database. For example:
    #
    #    class MyModel < ActiveRecord::Base
    #      acts_as_tableless [:first_name, :last_name]
    #      validates_presence_of :last_name
    #    end
    #    
    #    mine = MyModel.new(:first_name => 'John')
    #    mine.valid?              # false
    #    mine.last_name = 'Doe'
    #    mine.valid?              # true
    def acts_as_tableless(attributes)
      attributes = [attributes].flatten
      
      class_eval do
        self.abstract_class = true
        
        cattr_accessor :tableless_attributes
        
        self.tableless_attributes = attributes
       
        attributes.each{|attr| attr_accessor attr}

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
      end #class_eval

      include InstanceMethods
    end # acts_as_tableless
  end # ClassMethods
  
  module InstanceMethods
    # Returns the contents of the record just like a nice AR::Base object
    def tableless_attribute_for_inspect(attr_name)
      value = self.send(attr_name)
      
      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end
    
    # Format a tableless model's inspect just like a nice AR::Base object
    def inspect
      attributes_as_nice_string = self.class.tableless_attributes.collect{|name| "#{name}: #{tableless_attribute_for_inspect(name)}"}
      "#<#{self.class} #{attributes_as_nice_string.join(', ')}>"
    end
  end
end
