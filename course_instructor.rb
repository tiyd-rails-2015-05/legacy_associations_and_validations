class CourseInstructor < ActiveRecord::Base
  belongs_to :courses, dependent: :delete
end
