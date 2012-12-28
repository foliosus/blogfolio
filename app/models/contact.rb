class Contact < ActiveRecord::Base
  include Captcha
  
  acts_as_tableless [:name, :email, :email_confirmation, :subject, :body]
  
  email_name_regex  = '[\w\.%\+\-]+'.freeze
  domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i

  validates_presence_of     [:name, :email, :email_confirmation, :subject, :body]
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_format_of       :email,    :with => email_regex, :message => "doesn't appear to be a valid email address"
  validate                  :email_is_confirmed
  
  DEFAULT_EMAIL = 'Foliosus Web Design <foliosus@foliosus.com>'
  
  def email_is_confirmed
    errors.add(:email_confirmation, 'must match the email address') unless self.email == self.email_confirmation
  end
  
  def self.default_email
    DEFAULT_EMAIL
  end
end
