module Captcha
  CORRECT_ANSWER = 'why'
  
  def self.included(base)
    base.class_eval do
      attr_accessor :captcha
      validate :captcha_is_correct
    end
    
    def captcha_is_correct
      errors.add(:captcha, "must be filled out correctly") unless self.captcha && self.captcha.downcase == CORRECT_ANSWER
    end
  end
end