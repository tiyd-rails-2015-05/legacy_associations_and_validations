class School < ActiveRecord::Base
  has_many :terms

  validates :name, presence: true

  default_scope { order('name') }

  def assign_term(term)
    terms << term
  end

end
