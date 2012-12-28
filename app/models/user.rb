require 'digest/sha1'
class User < ActiveRecord::Base
  cattr_accessor :current_user
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation
  
  ROLES = [:none, :admin]
  
  include ModelSecurity
  @permissions = {:create => :admin, :read => :admin, :update => :admin, :delete => :admin}

  # Translate the role from a string to a symbol for use
  def role
    the_role = self.read_attribute(:role)
    if the_role 
      the_role.to_sym
    else
      nil
    end
  end
  
  # Store the role as a symbol
  def role=(new_role)
    if new_role
      write_attribute(:role, new_role.to_s) if ROLES.include?(new_role.to_sym)
    else
      write_attribute :role, nil
    end
  end
  
  # Does the user have the given access role or greater?
  def has_role?(role)
    self.role? ? self.role_rank >= (ROLES.index(role.to_sym) || 0) : false
  end
  
  # Numerical rank of the role, defaulting to zero (none)
  def role_rank
    self.role? ? ROLES.index(self.role) || 0 : 0
  end
  
  # Can the user CRUD a particular model? This <code>method_missing</code> creates methods like
  #   user.can_read_news_item?
  #   user.can_create_event?
  def method_missing_with_security(method_called, *args, &block)
    match = method_called.to_s.match(/^can_(#{ModelSecurity::GOVERNED_ACTIONS.join('|')})_(\w*?)\?$/)
    if match
      klass = match[2].camelize.constantize
      self.has_role?(klass.send("#{match[1]}_permission"))
    else
      method_missing_without_security(method_called, *args, &block)
    end
  end
  alias_method_chain :method_missing, :security

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  # List all users
  def self.list
    self.find(:all, :order => 'login ASC')
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
