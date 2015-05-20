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
