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

    assert reading_one.save
    assert reading_two.save
    assert_equal 1, Lesson.count
    assert_equal 2, Reading.count
    assert lesson_one.destroy
    assert_equal 0, Lesson.count
    assert_equal 0, Reading.count
  end

  def test_create_course
    assert math = Course.create(name: "math")
  end

  def test_add_lessons_course
    math = Course.create(name: "math")
    lesson_one = Lesson.create(name: "Lesson One")
    lesson_two = Lesson.create(name: "Lesson Two")

    assert math.add_lesson(lesson_one)
    assert math.add_lesson(lesson_two)
  end

  def test_destroying_course_destroys_lessons
    math = Course.create(name: "math")
    lesson_one = Lesson.create(name: "Lesson One")
    lesson_two = Lesson.create(name: "Lesson Two")
    math.add_lesson(lesson_one)
    math.add_lesson(lesson_two)

    assert lesson_one.save
    assert lesson_two.save
    assert_equal 1, Course.count
    assert_equal 2, Lesson.count
    assert math.destroy
    assert_equal 0, Course.count
    assert_equal 0, Lesson.count
  end

  def test_create_course_instructor
    prof = CourseInstructor.create
  end

  def test_add_course_to_course_instructor
    prof = CourseInstructor.create
    math = Course.create

    assert math.add_instructor(prof)
  end

  def test_course_is_not_destroyes_if_has_instructor
    prof = CourseInstructor.create
    math = Course.create
    math.add_instructor(prof)

    assert prof.save
    refute math.destroy
  end

  def test_course_has_many_readings

    math = Course.create(name: "math")
    lesson_one = Lesson.create(name: "Lesson One")
    lesson_two = Lesson.create(name: "Lesson Two")
    math.add_lesson(lesson_one)
    math.add_lesson(lesson_two)
    lesson_one.save
    lesson_two.save
    reading_one = Reading.create(caption:"Reading One", url:"google.com")
    reading_two = Reading.create(caption:"Reading Two", url:"ign.com")
    reading_three = Reading.create(caption:"Reading Three", url:"reddit.com")
    lesson_one.add_reading(reading_one)
    lesson_one.add_reading(reading_two)
    lesson_two.add_reading(reading_three)
    reading_one.save
    reading_two.save
    reading_three.save

    assert math.readings.count
  end

  def test_school_has_name
    assert School.create(name: "NC State")
    assert_raises ActiveRecord::RecordInvalid do
      School.create!(name: "")
    end
  end

  def test_term_has_name
    assert Term.create(name: "Summer")
    assert_raises ActiveRecord::RecordInvalid do
      Term.create!(name: "")
    end
  end

  def test_term_has_starts_on
    assert Term.create(name: "Summer", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Term.create!(name:"Summer", starts_on: "")
    end
  end

  def test_term_has_end_on
    assert Term.create(name: "Summer", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Term.create!(name:"Summer", starts_on: "06/05/15", ends_on: "")
    end
  end

  def test_term_has_school_id
    assert Term.create(name: "Summer", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Term.create!(name:"Summer", starts_on: "06/05/15", ends_on: "12/01/1", school_id: nil)
    end
  end

  def test_user_has_first_and_last_name
    assert User.create(first_name: "Testy", last_name: "Tester")
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name:"", last_name: "Tester")
    end
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name:"Testy", last_name: "")
    end
  end

  def test_user_has_email
    assert User.create(first_name: "Testy", last_name: "Tester", email: "testme@example.com")
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name:"Testy", last_name: "Tester", email: "")
    end
  end

  def test_email_is_unique
    user_one = User.create(first_name: "Testy", last_name: "Tester", email: "testme@example.com")
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name: "John", last_name: "Rambo", email: "testme@example.com")
    end
  end

  def test_format_of_user_email
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name: "John", last_name: "Rambo", email: "testmeexample.com")
    end
  end

  def test_school_term_association
    school = School.new(name: "NCSU")
    term1 = Term.new(name: "Fall", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    term2 = Term.new(name: "Spring", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)

    school.assign_term(term1)

    assert school.save
    assert term1.save
    assert term2.save

    assert_equal school.id, Term.last.school_id
  end

  def test_term_course_association
    fall_term = Term.create(name: "Fall", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    aero = Course.new(name: "Intro to Aero")

    fall_term.assign_course(aero)

    assert_equal fall_term.id, Course.last.term_id
  end

  def test_term_with_courses_cant_be_deleted
    fall_term = Term.create(name: "Fall", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
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
