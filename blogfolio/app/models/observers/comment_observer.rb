class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    AdminNotifier.deliver_comment_creation_email(comment)
  end
end
