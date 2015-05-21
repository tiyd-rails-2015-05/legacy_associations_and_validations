class CourseInstructor < ActiveRecord::Base
  belongs_to :courses, dependent: :restrict_with_errors
end
