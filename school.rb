class School < ActiveRecord::Base
  validates :name, presence: true
  has_many :terms

  default_scope { order('name') }
end
