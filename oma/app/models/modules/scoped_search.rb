module ScopedSearch
  def self.included(base)
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    # Return the publically searchable named scopes for the class
    def public_scopes
      self.scopes.collect{|k,v| k} - self::EXCLUDED_SCOPES - [:scoped]
    end
    
    # Return the "mutually exclusive" searchable named scopes for the class
    def exclusive_scopes
      self::EXCLUSIVE_SCOPES
    end
    
    # Prepare (based on params hash) a nested scopes statement that is restricted to the appropriate scopes for the class
    def prepare_scope_statement(queried_scopes = [], search = nil)
      if User.current_user && User.current_user.has_role?(:secretary)
        if queried_scopes.blank?
          current_scopes = self::DEFAULT_SCOPES
        else
          scopes = queried_scopes.collect{|s| s.to_sym}.select{|s| public_scopes.include?(s)}
          excl_scopes = scopes.select{|s| exclusive_scopes.include?(s)}
          case excl_scopes.length
            when 0 then current_scopes = self::DEFAULT_SCOPES
            when 1 then current_scopes = excl_scopes
            else current_scopes = [excl_scopes.first]
          end
          current_scopes += (scopes - excl_scopes)
        end
      else
        current_scopes = self::DEFAULT_SCOPES
      end

      scopes_statement = current_scopes.collect{|s| s.to_s}.join('.')
      scopes_statement += ".named(search)" unless search.blank?

      return [scopes_statement, current_scopes]
    end
    
    # Load a scoped search
    def load_by_scoped_search(queried_scopes = [], search = nil, page = 1)
      scopes_statement, current_scopes = prepare_scope_statement(queried_scopes, search)
      
      [eval("self.#{scopes_statement}.paginate(:page => #{page})"), current_scopes]
    end
    
    # Count a scoped search
    def count_by_scoped_search(queried_scopes = [], search = nil)
      scopes_statement, current_scopes = prepare_scope_statement(queried_scopes, search)
      results = eval("self.#{scopes_statement}.all")
      [results.length, current_scopes]
      # [eval("self.#{scopes_statement}.count"), current_scopes]
    end
  end # class methods

  module ModelInstanceMethods
  end # instance methods
end