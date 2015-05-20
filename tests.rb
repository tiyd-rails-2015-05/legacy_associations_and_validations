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
    myschool = School.create
    fall = Term.create(school_id: myschool.id)
    spring = Term.create(school_id: myschool.id)

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

  def test_course_has_many_students
    science = Course.create(name: "Science")
    joe = CourseStudent.create(course_id: science.id)
    anna = CourseStudent.create(course_id: science.id)

    assert_equal 2, science.course_students.count
  end

  def test_course_with_students_cant_be_deleted
    science = Course.create(name: "Science")
    joe = CourseStudent.create(course_id: science.id)
    anna = CourseStudent.create(course_id: science.id)

    refute science.destroy
  end

  def test_course_has_many_assignments
    science = Course.create(name: "Science")
    monday = Assignment.create(course_id: science.id)
    tuesday = Assignment.create(course_id: science.id)

    assert_equal 2, science.assignments.count
  end

  def test_assignments_get_deleted_with_course
    science = Course.create(name: "Science")
    monday = Assignment.create(course_id: science.id)
    tuesday = Assignment.create(course_id: science.id)

    assert_equal 2, Assignment.count

    science.destroy

    assert_equal 0, Assignment.count
  end

  def test_school_has_many_courses
    myschool = School.create
    fall = Term.create(school_id: myschool.id)
    math = Course.create(name: "Math", term_id: fall.id)
    science = Course.create(name: "Science", term_id: fall.id)

    assert_equal 2, myschool.courses.count
  end

  def test_lessons_must_have_names
    assert_raises(ActiveRecord::RecordInvalid) do
      Lesson.create!(name: "")
    end
  end

  def test_readings_must_order_number_lesson_id_and_url
    hyperion = Reading.create(order_number: 2, lesson_id: 1, url: "http://hyperion.com")

    assert hyperion
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
    book = Reading.create(lesson_id: l.id)
    other_book = Reading.create(lesson_id: l.id)
    assert_equal 2, l.readings.count
  end

  def test_readings_destroyed_with_lesson
    l = Lesson.create(name: "Validation")
    book = Reading.create(lesson_id: l.id)
    other_book = Reading.create(lesson_id: l.id)
    assert_equal 1, Lesson.count
    assert_equal 2, Reading.count
    l.destroy!
    assert_equal 0, Lesson.count
    assert_equal 0, Reading.count
  end

  def test_assign_lesson_to_course
    rails = Course.create(name: "Rails")
    validation = Lesson.create(name: "Validation", course_id: rails.id)
    git_messes = Lesson.create(name: "Git Messes", course_id: rails.id)
    assert_equal 2, rails.lessons.count
  end

  def test_lessons_destroyed_with_course
    rails = Course.create(name: "Rails")
    validation = Lesson.create(name: "Validation", course_id: rails.id)
    git_messes = Lesson.create(name: "Git Messes", course_id: rails.id)
    rails.destroy!
    assert_equal 0, Course.count
    assert_equal 0, Lesson.count
  end
end
