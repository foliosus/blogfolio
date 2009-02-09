class Comment < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:update => :admin, :delete => :admin}

  belongs_to    :post
  
  validates_presence_of   :author
  validates_presence_of   :email
  validates_presence_of   :body
end
