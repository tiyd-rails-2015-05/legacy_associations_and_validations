class School < ActiveRecord::Base
  validates

  default_scope { order('name') }
end
