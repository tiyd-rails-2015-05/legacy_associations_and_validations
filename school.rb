class School < ActiveRecord::Base
  default_scope { order('name') }

  has_many :terms

end
