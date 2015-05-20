# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3')

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

  def test_create_lesson
    assert lesson = Lesson.create(name: "Lesson One")
  end

  def test_create_reading
    assert reading = Reading.create(caption:"Reading One", url:"google.com")
  end

  def test_add_reading_to_lesson
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(caption:"Reading One", url:"google.com")

    assert lesson_one.add_reading(reading_one)
    assert_equal lesson_one.id, Reading.last.lesson_id
  end

  def test_lesson_has_many_readings
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(caption:"Reading One", url:"google.com")
    reading_two = Reading.create(caption:"Reading Two", url:"ign.com")
    lesson_one.add_reading(reading_one)
    lesson_one.add_reading(reading_two)

    assert_equal 2, lesson_one.readings.count
  end

  def test_destroy_lesson_with_reading
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(caption:"Reading One", url:"google.com")
    reading_two = Reading.create(caption:"Reading Two", url:"ign.com")
    lesson_one.add_reading(reading_one)
    lesson_one.add_reading(reading_two)
    reading_one.save
    reading_two.save
    assert lesson_one.destroy

    assert_equal 0, Lesson.count
    assert_equal 0, Reading.count
  end

  def test_create_course
    assert math = Course.create(name: "math")
  end

  def test_school_term_association
    school = School.new(name: "NCSU")
    term1 = Term.new(name: "Fall")
    term2 = Term.new(name: "Spring")

    school.assign_term(term1)

    assert school.save
    assert term1.save
    assert term2.save

    assert_equal school.id, Term.last.school_id
  end

  def test_term_course_association
    fall_term = Term.create(name: "Fall")
    aero = Course.new(name: "Intro to Aero")

    fall_term.assign_course(aero)

    assert_equal fall_term.id, Course.last.term_id
  end

  def test_term_with_courses_cant_be_deleted
    fall_term = Term.create(name: "Fall")
    aero = Course.new(name: "Intro to Aero")

    fall_term.assign_course(aero)

    refute Term.last.destroy
  end

  def test_course_student_association
    aero = Course.create(name: "Intro to Aero")
    john = CourseStudent.new(student_id: 1)

    aero.assign_student(john)

    refute Course.last.destroy
  end

end
