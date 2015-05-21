class CourseInstructor < ActiveRecord::Base

  belongs_to :courses
  has_many :instructors, class_name: "User", foreign_key: "instructor_id"

end
