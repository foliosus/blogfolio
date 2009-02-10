module Captcha
  CORRECT_ANSWER = 'yes'
  
  def self.included(base)
    base.class_eval do
      attr_accessor :captcha
      validate :captcha_is_correct
    end
    
    def captcha_is_correct
      errors.add(:captcha, "must be filled out correctly") unless self.captcha.downcase == CORRECT_ANSWER
    end
  end
end