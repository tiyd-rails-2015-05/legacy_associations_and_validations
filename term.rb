class Term < ActiveRecord::Base

  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  belongs_to :school
  has_many :courses, dependent: :restrict_with_error

  def school_name
    school ? school.name : "None"
  end
end
