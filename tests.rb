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
    # Associate lessons with readings (both directions).
    lesson = Lesson.create(name: "Addition")
    r1 = Reading.create(caption: "1", lesson_id: lesson.id)
    r2 = Reading.create(caption: "2", lesson_id: lesson.id)
    r3 = Reading.create(caption: "3", lesson_id: lesson.id)
    assert_equal lesson, r1.lesson
    assert_equal lesson, r2.lesson
    assert_equal lesson, r3.lesson
  end

  def test_lesson_destroyed_destroys_readings
    # When a lesson is destroyed, its readings should be automatically destroyed
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

  def test_associate_lessons_with_courses_and_dependecy
    # Associate lessons with courses (both directions). When a course is destroyed, its lessons should be automatically destroyed.
    course = Course.create(name: "Mexican History")
    l1 = Lesson.create(course_id: course.id, name: "l1")
    l2 = Lesson.create(course_id: course.id, name: "l2")
    l3 = Lesson.create(course_id: course.id, name: "l3")
    assert_equal course, l1.course
    assert_equal course, l2.course
    assert_equal course, l3.course
    assert_equal 1, Course.count
    assert_equal 3, Lesson.count
    course.destroy
    assert_equal 0, Course.count
    assert_equal 0, Lesson.count
  end

  def test_associate_courses_with_course_instructors
    # Associate courses with course_instructors (both directions). If the course has any students associated with it, the course should not be deletable.
    biology = Course.create(name: "Biology")
    gym = Course.create(name: "Gym Class")

    student = CourseStudent.create(course_id: biology.id)

    instructor1 = CourseInstructor.create(course_id: biology.id)
    instructor2 = CourseInstructor.create(course_id: gym.id)

    assert_equal biology, instructor1.course
    assert_equal gym, instructor2.course
    assert gym.destroy
    refute biology.destroy
  end

  # def test_associate_lessons_with_their_in_class_assignments
  #   # Associate lessons with their in_class_assignments (both directions).
  #   assignment = Assignment.create(name: "Write your name.")
  #   lesson = Lesson.create(in_class_assignments_id: assignment.id)
  #
  # end

  def test_course_has_many_readings_through_course_lessons
    # Set up a Course to have many readings through the Course's lessons.
    biology = Course.create(name: "Integer Math")
    lesson = Lesson.create(name: "Addition", course_id: biology.id)
    r1 = Reading.create(caption: "1", lesson_id: lesson.id)
    r2 = Reading.create(caption: "2", lesson_id: lesson.id)
    r3 = Reading.create(caption: "3", lesson_id: lesson.id)

    assert_equal [r1, r2, r3], biology.readings
    assert_equal biology, r1.course
    assert_equal biology, r2.course
    assert_equal biology, r3.course
  end

  def test_validate_that_schools_must_have_name
    school1 = School.new
    school2 = School.new(name: "TIYD")
    refute school1.save
    assert school2.save
  end

  def test_validate_that_terms_must_have_name_starts_on_ends_on_and_school_id
    # Validate that Terms must have name, starts_on, ends_on, and school_id.
    school = School.create(name: "TIYD")
    term1 = Term.new(na)
    term2 = Term.new(name: "string",
        starts_on: 2013-04-12 ((2456395j,0s,0n),+0s,2299161j),
        ends_on: 2015-05-21 ((2457164j,0s,0n),+0s,2299161j),
        school_id: school.id
    )


  end
end
