class CourseInstructor < ActiveRecord::Base
  has_many :courses
end
