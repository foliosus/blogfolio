module ModelSecurity
  
  GOVERNED_ACTIONS = [:create, :read, :update, :delete]
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class << self
        attr_accessor :permissions
        alias_method_chain :method_missing, :model_security
        alias_method_chain :delete_all, :model_security
        alias_method_chain :delete, :model_security
      end
      
      include InstanceMethods
      alias_method_chain :create_or_update, :security_check
      alias_method_chain :destroy, :security_check
      alias_method_chain :initialize, :security_check
    end
  end

  module ClassMethods
    # Does the User.current_user have permission to do perm?
    def current_user_has_permission(perm)
      !(self.permissions.keys.include?(perm) && (User.current_user && !User.current_user.send("can_#{perm}_#{self.to_s.underscore.downcase}?")))
    end
    
    # On models with security, find out what the minimum permission is to accomplish a CRUD task
    def method_missing_with_model_security(method_called, *args, &block)
      match = method_called.to_s.match(/^(#{GOVERNED_ACTIONS.collect{|a| a.to_s}.join('|')})_permission$/)
      if match
        @permissions.keys.include?(match[1].to_sym) ? @permissions[match[1].to_sym] : :none
      else
        method_missing_without_model_security(method_called, *args, &block)
      end
    end
    
    # Raise an error when attempting to <code>delete_all</code> unless user has proper clearance
    def delete_all_with_model_security(*args)
      raise NotAuthorized unless current_user_has_permission(:delete)
      delete_all_without_model_security(*args)
    end

    # Raise an error when attempting to <code>delete</code> unless user has proper clearance
    def delete_with_model_security(*args)
      raise NotAuthorized unless current_user_has_permission(:delete)
      delete_without_model_security(*args)
    end
    
  end # class methods

  module InstanceMethods
    def current_user_has_permission(perm)
      !(self.class.permissions.keys.include?(perm) && (User.current_user && !User.current_user.send("can_#{perm}_#{self.class.to_s.underscore.downcase}?")))
    end
    
    # Raise an error when attempting to save or save! a record unless user has proper clearance
    def create_or_update_with_security_check
      if self.new_record?
        raise NotAuthorized unless current_user_has_permission(:create)
      else
        raise NotAuthorized unless current_user_has_permission(:update)
      end
      create_or_update_without_security_check
    end
    
    # Raise an error when attempting to destroy a record unless user has proper clearance
    def destroy_with_security_check(*args)
      raise NotAuthorized unless current_user_has_permission(:delete)
      destroy_without_security_check(*args)
    end

    # Raise an error when attempting to read a record unless user has proper clearance
    def initialize_with_security_check(*args)
      raise NotAuthorized unless current_user_has_permission(:read)
      initialize_without_security_check(*args)
    end
    
  end # instance methods
end