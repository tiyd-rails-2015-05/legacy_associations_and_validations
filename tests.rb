# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'

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

ActiveRecord::Migration.verbose = false
# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def setup
    ApplicationMigration.migrate(:up)
  end

  def teardown
    ApplicationMigration.migrate(:down)
  end

  def test_truth
    assert true
  end

  def test_school_term_association
    ews = School.create(name: "EWS")
    spring = Term.create(name: "spring", school_id: ews.id)
    assert_equal spring, ews.terms.first
  end

  def test_term_course_association
    spring = Term.create(name: "spring")
    math = Course.create(name: "calc 2", term_id: spring.id)
    assert_equal math, spring.courses.first
    refute spring.destroy
  end

  def test_course_course_student_association
    math = Course.create(name: "calc 2")
    emily = CourseStudent.create(course_id: math.id)
    assert_equal emily, math.course_students.first
    refute math.destroy
  end

  def test_course_assignment_association
    math = Course.create(name: "calc 2")
    homework = Assignment.create(course_id: math.id)
    assert_equal homework, math.assignments.first
    assert math.destroy
  end

  # def test_lesson_pre_work_association
  #   homework = Assignment.create(name: "homework")
  #   planning = Lesson.create(pre_class_assignment_id: homework.id)
  #   assert_equal homework, planning.pre_class_assignment
  # end

  def test_school_course_association
    ews = School.create(name: "EWS")
    spring = Term.create(name: "spring", school_id: ews.id)
    math = Course.create(name: "calc 2", term_id: spring.id)
    assert_equal math, ews.courses.first
  end

  def test_lessons_readings_association
    world_war_2 = Lesson.create(name: "World War 2")
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id)
  end

  def test_lessons_must_have_names
    planning = Lesson.new(name: "how to plan stuff")
    free_play = Lesson.new
    assert planning.save
    refute free_play.save
  end


  def test_readings_destroyed_with_lessons
    world_war_2 = Lesson.create(name: "World War 2")
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id)
    assert_equal 1, Lesson.count
    world_war_2.destroy
    assert_equal 0, Lesson.count
  end


end
