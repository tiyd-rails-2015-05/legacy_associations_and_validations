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

#Silence those pesky migration messages
ActiveRecord::Migration.verbose = false

# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  # Gotta run migrations before we can run tests.  Down will fail the first time,
  # so we wrap it in a begin/rescue.
  def setup
    ApplicationMigration.migrate(:up)
  end

  def teardown
    ApplicationMigration.migrate(:down)
  end

  def test_truth
    assert true
  end

  def test_false
    refute false
  end

  def test_associate_lessons_with_readings
    # Associate lessons with readings (both directions). When a lesson is destroyed, its readings should be automatically destroyed.
    lesson = Lesson.create(name: "Addition")
    r1 = Reading.create(caption: "1", lesson_id: lesson.id)
    r2 = Reading.create(caption: "2", lesson_id: lesson.id)
    r3 = Reading.create(caption: "3", lesson_id: lesson.id)

    assert_equal lesson, r1.lesson
    assert_equal lesson, r2.lesson
    assert_equal lesson, r3.lesson
  end

  def test_lesson_destroyed_destroys_readings
    lesson = Lesson.create(name: "Addition")
    r1 = Reading.create(caption: "1", lesson_id: lesson.id)
    r2 = Reading.create(caption: "2", lesson_id: lesson.id)
    r3 = Reading.create(caption: "3", lesson_id: lesson.id)
    assert_equal 1, Lesson.count
    assert_equal 3, Reading.count
    lesson.destroy
    assert_equal 0, Lesson.count
    assert_equal 0, Reading.count
  end

  # def test_associate_lessons_with_courses
  #   # Associate lessons with courses (both directions). When a course is destroyed, its lessons should be automatically destroyed.
  #   course = Course.create(name: "Mexican History")
  #   l1 = Lesson.create(course_id: course.id, name: "l1")
  #   l2 = Lesson.create(course_id: course.id, name: "l2")
  #   l3 = Lesson.create(course_id: course.id, name: "l3")
  # end
end
