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

ActiveRecord::Migration.verbose = false

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_school_has_many_terms
    myschool = School.create
    fall = Term.create
    spring = Term.create
    spring.update(school_id: myschool.id)
    fall.update(school_id: myschool.id)

    assert_equal 2, myschool.terms.count
  end

  def test_term_has_many_courses
    fall = Term.create
    math = Course.create(name: "Math", term_id: fall.id)
    science = Course.create(name: "Science", term_id: fall.id)

    assert_equal 2, fall.courses.count
  end

  def test_term_with_courses_cant_be_deleted
    fall = Term.create
    math = Course.create(name: "Math", term_id: fall.id)
    science = Course.create(name: "Science", term_id: fall.id)

    refute fall.destroy
  end

  def test_course_with_students_cant_be_deleted
    science = Course.create(name: "Science")
    joe = CourseStudent.create(course_id: science.id)
    anna = CourseStudent.create(course_id: science.id)

    refute science.destroy
  end

  def test_truth
    assert true
  end

end
