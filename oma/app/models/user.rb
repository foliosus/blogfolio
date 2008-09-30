require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  include ModelSecurity
  @permissions = {:create => :secretary, :read => :secretary, :update => :secretary, :delete => :secretary}

  has_one :member
  has_many :classifieds, :through => :member

  ROLES = [:none, :member, :secretary, :board, :administrator]

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  validates_inclusion_of    :role, :in => ROLES, :allow_nil => true

  before_validation_on_create :generate_random_password
  before_create :make_activation_code

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :name, :password, :password_confirmation

  cattr_accessor :current_user
  
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  # Resets a user's password
  def reset_password!
    generate_random_password
    make_activation_code
    self.force_password_reset = true
    @reset = true
    save
  end
  
  def recently_reset?
    @reset
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def member_id
    self.member.id unless self.member.nil?
  end
  
  def member_id=(new_id)
    if new_id
      self.member.update_attributes(:user_id => nil) unless self.member.nil?
      Member.find(new_id).update_attributes(:user_id => self.id)
    else
      self.member.user_id = nil unless self.member.nil?
    end
  end
  
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
    self.role? ? ROLES.index(self.role) >= ROLES.index(role.to_sym) : false
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

  protected
    
    def make_activation_code
        self.activation_code = self.class.make_token
    end
    
    # Generate a random password unless one is already specified
    def generate_random_password
      self.password = self.password_confirmation = self.class.make_token[32..39] unless self.password
    end
    
end
