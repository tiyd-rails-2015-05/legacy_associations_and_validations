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
# begin ApplicationMigration.migrate(:down); rescue; end
# ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def setup
    ApplicationMigration.migrate(:up)
  end

  def teardown
    ApplicationMigration.migrate(:down)
  end

  #Person A
  def test_school_has_many_terms
    myschool = School.create(name: "The Iron Yard")
    fall = Term.create(school_id: myschool.id, name: "Fall", starts_on: 2015-05-04,
    ends_on: 2015-07-24)
    spring = Term.create(school_id: myschool.id, name: "spring", starts_on: 2015-05-04,
    ends_on: 2015-07-24)

    assert_equal 2, myschool.terms.count
  end

  def test_term_has_many_courses
    fall = Term.create(school_id: 1, name: "Fall", starts_on: 2015-05-04,
    ends_on: 2015-07-24)
    math = Course.create(name: "Math", term_id: fall.id, course_code: "MAT402")
    science = Course.create(name: "Science", term_id: fall.id, course_code: "SCI402")

    assert_equal 2, fall.courses.count
  end

  def test_term_with_courses_cant_be_deleted
    fall = Term.create(name: "Fall", starts_on: 2015-05-04, ends_on: 2015-07-24, school_id: 1)
    math = Course.create(name: "Math", term_id: fall.id, course_code: "MAT402")
    science = Course.create(name: "Science", term_id: fall.id, course_code: "SCI402")
    refute fall.destroy
  end

  def test_course_has_many_students
    science = Course.create(name: "Science", term_id: 1, course_code: "SCI402")
    joe = CourseStudent.create(course_id: science.id)
    anna = CourseStudent.create(course_id: science.id)

    assert_equal 2, science.course_students.count
  end

  def test_course_with_students_cant_be_deleted
    science = Course.create(name: "Science", course_code: "SCI304")
    joe = CourseStudent.create(course_id: science.id)
    anna = CourseStudent.create(course_id: science.id)

    refute science.destroy
  end

  def test_course_has_many_assignments
    science = Course.create(name: "Science", course_code: "SCI304")
    monday = Assignment.create(course_id: science.id)
    tuesday = Assignment.create(course_id: science.id)

    assert_equal 2, science.assignments.count
  end

  def test_assignments_get_deleted_with_course
    science = Course.create(name: "Science", course_code: "SCI304")
    monday = Assignment.create(course_id: science.id)
    tuesday = Assignment.create(course_id: science.id)

    assert_equal 2, Assignment.count

    science.destroy

    assert_equal 0, Assignment.count
  end

  def test_school_has_many_courses
    myschool = School.create(name: "The Iron Yard")
    fall = Term.create(school_id: myschool.id, name: "Fall", starts_on: 2015-05-04,
    ends_on: 2015-07-24)
    math = Course.create(name: "Math", term_id: fall.id, course_code: "MAT304")
    science = Course.create(name: "Science", term_id: fall.id, course_code: "SCI402")

    assert_equal 2, myschool.courses.count
  end

  def test_lessons_must_have_names
    assert_raises(ActiveRecord::RecordInvalid) do
      Lesson.create!(name: "")
    end
  end

  def test_courses_must_be_unique
    fall = Term.create(school_id: 1)
    spring = Term.create(school_id: 1)
    math = Course.create!(name: "Math", term_id: fall.id, course_code: "MAT304")
    science = Course.create!(name: "Science", term_id: fall.id, course_code: "SCI402")
    history2 = Course.create!(name: "History", term_id: spring.id, course_code: "HIS402")

    assert math
    assert science
    assert_raises(ActiveRecord::RecordInvalid) do
      history = Course.create!(name: "History", term_id: fall.id, course_code: "HIS402")
    end
    assert history2

  end

  def test_readings_must_order_number_lesson_id_and_url
    hyperion = Reading.create(order_number: 2, lesson_id: 1, url: "http://hyperion.com")

    assert hyperion
  end

  def test_reading_url_must_start_with_http
    assert Reading.create!(order_number: 2, lesson_id: 1, url: "http://hyperion.com")
    assert Reading.create!(order_number: 2, lesson_id: 1, url: "https://hyperion.com")
    assert_raises(ActiveRecord::RecordInvalid) do
      Reading.create!(order_number: 2, lesson_id: 1, url: "htt://hyperion.com")
    end
  end

  def test_truth
    assert true
  end



  ###Person B
  def test_create_lesson
    assert Lesson.create(name: "Validation")
  end

  def test_create_reading
    assert Reading.create
  end

  def test_destroy_lesson
    l = Lesson.create(name: "Validation")
    assert 1, Lesson.count
    l.destroy!
    assert 0, Lesson.count
  end

  def test_assign_reading_to_lesson
    l = Lesson.create(name: "Validation")
    book = Reading.create(lesson_id: l.id, order_number: 2, url: "http://hyperion.com")
    other_book = Reading.create(lesson_id: l.id, order_number: 3, url: "http://hanother.com")
    assert_equal 2, l.readings.count
    assert_equal [book, other_book], l.readings
  end

  def test_readings_destroyed_with_lesson
    l = Lesson.create(name: "Validation")
    book = Reading.create(lesson_id: l.id, order_number: 2, url: "http://hyperion.com")
    other_book = Reading.create(lesson_id: l.id, order_number: 3, url: "http://hanother.com")
    assert_equal 1, Lesson.count
    assert_equal 2, Reading.count
    l.destroy!
    assert_equal 0, Lesson.count
    assert_equal 0, Reading.count
  end

  def test_assign_lesson_to_course
    rails = Course.create(name: "Rails", course_code: "RAI304")
    validation = Lesson.create(name: "Validation", course_id: rails.id)
    git_messes = Lesson.create(name: "Git Messes", course_id: rails.id)
    assert_equal 2, rails.lessons.count
    assert_equal rails.id, validation.course_id
  end

  def test_lessons_destroyed_with_course
    rails = Course.create(name: "Rails", course_code: "RAI304")
    validation = Lesson.create(name: "Validation", course_id: rails.id)
    git_messes = Lesson.create(name: "Git Messes", course_id: rails.id)
    rails.destroy!
    assert_equal 0, Course.count
    assert_equal 0, Lesson.count
  end

  def test_courses_associated_with_course_instructors
    rails = Course.create(name: "Rails", course_code: "RAI304")
    mason = CourseInstructor.create(course_id: rails.id)
    assert_equal 1, rails.course_instructors.count
    assert_equal [mason], rails.course_instructors
    assert_equal rails.id, mason.course_id
  end

  def test_courses_with_instructors_cant_be_destroyed
    rails = Course.create(name: "Rails", course_code: "RAI304")
    mason = CourseInstructor.create(course_id: rails.id)
    assert_raises(ActiveRecord::RecordNotDestroyed) do
      rails.destroy!
    end
  end

  #in-class assignment stuff here

  def test_courses_have_many_readings_through_lessons
    rails = Course.create(name: "Rails", course_code: "RAI304")
    validation = Lesson.create(name: "Validation", course_id: rails.id)
    book = Reading.create(lesson_id: rails.id, order_number: 2, url: "http://hyperion.com")
    other_book = Reading.create(lesson_id: rails.id, order_number: 3, url: "http://hanother.com")

    assert_equal [book, other_book], rails.readings
  end

  def test_schools_must_have_names
    assert School.create!(name: "The Iron Yard")
    assert_raises(ActiveRecord::RecordInvalid) do
       School.create!(name: "")
     end
  end

  def test_terms_must_have_four_paramaters
    tiy = School.create(name: "The Iron Yard")
    assert Term.create(name: "Spring", starts_on: 2015-05-04, ends_on: 2015-07-24, school_id: tiy.id)
    assert_raises(ActiveRecord::RecordInvalid) do
      Term.create!(name: "", starts_on: 2015-05-04, ends_on: 2015-07-24, school_id: tiy.id)
    end
     assert_raises(ActiveRecord::RecordInvalid) do
      Term.create!(name: "Spring", ends_on: 2015-07-24, school_id: tiy.id)
    end
    assert_raises(ActiveRecord::RecordInvalid) do
      Term.create!(name: "Spring", starts_on: 2015-05-04, school_id: tiy.id)
    end
    assert_raises(ActiveRecord::RecordInvalid) do
      Term.create!(name: "Spring", starts_on: 2015-05-04, ends_on: 2015-07-24)
    end
  end

  def test_users_must_have_names_and_email
    assert User.create(first_name: "Homer", last_name: "Simpson", email: "homer@doh.com")
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "", last_name: "Simpson", email: "homer@doh.com")
    end
     assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "Homer", last_name: "", email: "homer@doh.com")
    end
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "Homer", last_name: "Simpson", email: "")
    end
  end

  def test_user_email_must_be_unique
    assert User.create(first_name: "Homer", last_name: "Simpson", email: "homer@doh.com")
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "Marge", last_name: "Simpson", email: "homer@doh.com")
    end
  end

  def test_user_photo_url_format_must_be_http
    assert User.create!(first_name: "Homer", last_name: "Simpson",
      email: "homer@doh.com", photo_url: "http://homer.com")
    assert User.create!(first_name: "Marge", last_name: "Simpson",
      email: "marge@bluehair.com", photo_url: "https://marge.com")
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "Bart", last_name: "Simpson",
      email: "bart@eatmyshorts.com", photo_url: "eatmyshorts.com")
    end
  end

  def test_user_email_format_correct
    assert User.create!(first_name: "Homer", last_name: "Simpson",
      photo_url: "http://homer.com", email: "homer9@doh.com")
    assert User.create!(first_name: "Marge", last_name: "Simpson",
      photo_url: "https://marge.com", email: "marge_rules@bluehair.com")
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(first_name: "Bart", last_name: "Simpson",
      photo_url: "eatmyshorts.com", email: "/bart&eatmyshorts_com")
    end
  end
end
