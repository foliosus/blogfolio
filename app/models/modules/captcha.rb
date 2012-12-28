module Captcha
  CORRECT_ANSWER = 'how'
  
  def self.included(base)
    base.class_eval do
      attr_accessor :captcha
      validate :captcha_is_correct
      
      attr_accessor :cap_size
      validate :honeypot_isnt_filled
    end
    
    def captcha_is_correct
      errors.add(:captcha, "must be filled out correctly") unless self.captcha && self.captcha.downcase == CORRECT_ANSWER
    end
    
    def honeypot_isnt_filled
      errors.add_to_base("Cap size must be filled out correctly") unless self.cap_size.blank?
    end
  end
end