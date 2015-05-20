# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)





# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

#how do I test this????
  def test_term_can_not_be_destroyed_if_courses_present
    term = Term.new(name: "Fall")
    course = Course.new(name: "Marching Band")

    assert term.save
    assert course.save

    term.destroy
    refute term.destroy
  end

#how do I test this????
  def test_course_can_not_be_destroyed_if_course_students_present
    course = Course.new(name: "Marching Band")
    students = CourseStudent.new(student_id: 1)

    assert course.save
    assert students.save

    course.destroy
    refute course.destroy


  end

#how do I test this????
  def test_assignments_are_destroyed_when_courses_are_destroyed
    course = Course.create(name: "Marching Band")
    course = Assignment.create(name: "Malaguena")
  end





end
