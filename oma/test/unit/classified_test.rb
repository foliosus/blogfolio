require 'test_helper'

class ClassifiedTest < ActiveSupport::TestCase
  def test_can_be_edited_by
    stub_user
    member = user.build_member
    user.role = :none
    classified = member.classifieds.build
    unattached_classified = Classified.new(:member_id => 2)
    assert !unattached_classified.can_be_edited_by?(user), "User with no role shouldn't be able to edit someone else's classified"
    assert classified.can_be_edited_by?(user), "User with no role should be able to edit their own classified"
    user.role = :secretary
    assert unattached_classified.can_be_edited_by?(user), "User with elevated privileges should be able to edit their own classified"
  end
end
