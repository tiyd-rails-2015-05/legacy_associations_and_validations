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
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"http://google.com", lesson_id: 1)

    assert lesson_one.add_reading(reading_one)
    assert_equal lesson_one.id, Reading.last.lesson_id
  end

  def test_lesson_has_many_readings
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"https://google.com", lesson_id: 1)
    reading_two = Reading.create(order_number: 2, caption:"Reading Two", url:"http://ign.com", lesson_id: 1)
    lesson_one.add_reading(reading_one)
    lesson_one.add_reading(reading_two)

    assert_equal 2, lesson_one.readings.count
  end

  def test_destroy_lesson_with_reading
    lesson_one = Lesson.create(name: "Lesson One")
    reading_one = Reading.create(order_number: 1, caption:"Reading One", url:"http://google.com", lesson_id: 1)
    reading_two = Reading.create(order_number: 2, caption:"Reading Two", url:"http://ign.com", lesson_id: 1)
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
    math = Course.create(name: "math", course_code: "ABC123")
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
    assert User.create!(first_name: "John", last_name: "Rambo", email: "test@example.com")
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name: "John", last_name: "Rambo", email: "testmeexample.com")
    end
  end

  def test_photo_url_uses_http
    assert User.create!(first_name: "John", last_name: "Rambo", email: "testme@example.com", photo_url: "http://www.ign.com")
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(first_name: "John", last_name: "Rambo", email: "testme@example.com", photo_url: "www.yahoo.com")
    end
  end

  def test_assignment_has_name
    assert Assignment.create!(name: "Homework", percent_of_grade: 20, course_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Assignment.create!(name: "", percent_of_grade: nil, course_id: 1)
    end
  end

  def test_assignment_has_percent_of_grade
    assert Assignment.create(name: "Homework", percent_of_grade: 20, course_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Assignment.create!(name: "Homework", percent_of_grade: nil, course_id: 1)
    end
  end

  def test_assignment_has_course_id
    assert Assignment.create!(name: "Homework", percent_of_grade: 20, course_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      Assignment.create!(name: "Homework", percent_of_grade: 20, course_id: "")
    end
  end

  def test_assigment_name_unique_if_same_course_id
    assert Assignment.create!(name: "Homework", percent_of_grade: 20, course_id: 1)
    assert_raises ActiveRecord::RecordInvalid do
      assert Assignment.create!(name: "Homework", percent_of_grade: 20, course_id: 1)
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
    aero = Course.new(name: "Intro to Aero", course_code: "ABC123")

    fall_term.add_course(aero)

    assert_equal fall_term.id, Course.last.term_id
  end

  def test_term_with_courses_cant_be_deleted
    fall_term = Term.create(name: "Fall", starts_on: "06/05/15", ends_on: "12/01/15", school_id: 1)
    aero = Course.new(name: "Intro to Aero", course_code: "ABC123")

    fall_term.add_course(aero)

    refute Term.last.destroy
  end

  def test_course_student_association
    aero = Course.create(name: "Intro to Aero", course_code: "ABC123")
    john = CourseStudent.new(student_id: 1)

    aero.add_student(john)

    refute Course.last.destroy
  end

  def test_assignment_courses_association
    aero = Course.create(name: "Intro to Aero", course_code: "ABC123")
    cruise_altitude = Assignment.new(name: "Cruise Altitude")

    aero.add_assignment(cruise_altitude)

    assert_equal aero.id, Assignment.last.course_id
  end

  def test_delete_course_also_deletes_assignments
    aero = Course.create(name: "Intro to Aero")
    cruise_altitude = Assignment.new(name: "Cruise Altitude")

    aero.add_assignment(cruise_altitude)

    assert aero.destroy
    assert_equal 0, Course.count
    assert_equal 0, Assignment.count
  end

  def test_school_has_many_courses
    ncsu = School.create(name: "NCSU")
    fall_term = Term.create(name: "Fall")
    spring_term = Term.create(name: "Spring")
    ncsu.assign_term(fall_term)
    ncsu.assign_term(spring_term)
    fall_term.save
    spring_term.save

    aero = Course.create(name: "Intro to Aero")
    structures = Course.create(name: "Aerospace Structures")
    cfd = Course.create(name: "CFD")

    fall_term.add_course(aero)
    fall_term.add_course(structures)
    spring_term.add_course(cfd)

    aero.save
    structures.save
    cfd.save

    assert ncsu.courses.count
  end

  def test_lesson_has_name
    assert Lesson.create(name: "Lesson One")
    assert_raises ActiveRecord::RecordInvalid do
      Lesson.create!(name: "")
    end
  end

def test_reading_has_order_number
  assert Reading.create(order_number: 1, lesson_id: 1, url: "google.com")
  assert_raises ActiveRecord::RecordInvalid do
    Reading.create!(order_number: nil)
  end
end

def test_reading_has_lesson_id
  assert Reading.create(order_number: 1, lesson_id: 1, url: "google.com")
    assert_raises ActiveRecord::RecordInvalid do
    Reading.create!(order_number: nil, lesson_id: nil)
  end
end

def test_reading_has_url
  assert Reading.create(order_number: 1, lesson_id: 1, url: "google.com")
  assert_raises ActiveRecord::RecordInvalid do
    Reading.create!(order_number: 1, lesson_id: 1, url: "")
  end
end

def test_courses_have_course_code
  assert Course.create(name: "Psych", course_code: "ABC123")
  assert_raises ActiveRecord::RecordInvalid do
    Course.create!(course_code: "")
  end
end

def test_reading_url_uses_http
  assert Reading.create!(order_number: 1, lesson_id: 1, url: "http://google.com")
  assert_raises ActiveRecord::RecordInvalid do
    Reading.create!(order_number: 1, lesson_id: 1, url: "google.com")
  end
end


end
