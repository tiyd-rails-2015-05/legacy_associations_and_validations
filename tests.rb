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
    spring = Term.create(name: "spring", school_id: ews.id, starts_on: '2013-04-04', ends_on: '2014-04-04')
    assert_equal spring, ews.terms.first
  end

  def test_term_course_association
    ews = School.create(name: "EWS")
    spring = Term.create(name: "spring", starts_on: '2015-04-04', ends_on: '2012-03-03', school_id: ews.id)
    math = Course.create(name: "calc 2", term_id: spring.id, course_code: 56)
    assert_equal math, spring.courses.first
    refute spring.destroy
  end

  def test_course_course_student_association
    math = Course.create(name: "calc 2",course_code: 56)
    emily = CourseStudent.create(course_id: math.id)
    assert_equal emily, math.course_students.first
    refute math.destroy
  end

  def test_course_assignment_association
    math = Course.create(name: "calc 2",course_code: 56)
    homework = Assignment.create(course_id: math.id)
    assert_equal homework, math.assignments.first
    assert math.destroy
  end

  def test_school_course_association
    ews = School.create(name: "EWS")
    spring = Term.create(name: "spring", starts_on: '2015-03-03', ends_on: '2015-05-05', school_id: ews.id)
    math = Course.create(name: "calc 2", term_id: spring.id,course_code: 56)
    assert_equal math, ews.courses.first
  end

  def test_lessons_must_have_names
    planning = Lesson.new(name: "how to plan stuff")
    free_play = Lesson.new
    assert planning.save
    refute free_play.save
  end

  def test_lessons_readings_association
    world_war_2 = Lesson.create(name: "World War 2")
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id)
    assert_equal 1, Lesson.count
  end

  def test_lessons_destroyed_with_courses
    us_history = Course.create(name: "US History",course_code: 2451)
    world_war_2 = Lesson.create(name: "World War 2", course_id: us_history.id)
    assert_equal 1, us_history.lessons.count
  end

  def test_readings_must_have_attributes
    lord_of_the_rings= Reading.new(order_number: 4, lesson_id: 6, url: "http://www.thebest.com")
    blank = Reading.new
    assert lord_of_the_rings.save
    refute blank.save
  end

  def test_url_correct
    clockwork_orange = Reading.new(order_number: 4, lesson_id: 6, url: "thebest")
    lord_of_the_rings= Reading.new(order_number: 4, lesson_id: 6, url: "http://www.thebest.com")
    refute clockwork_orange.save
    assert lord_of_the_rings.save
  end

  def test_courses_must_have_attributes
    math= Course.new(course_code: 56, name: "calc2")
    blank = Course.new
    assert math.save
    refute blank.save
  end


  def test_courses_associated_course_instructors
    us_history = Course.create(name: "US History",course_code: 2451)
    mr_turner = CourseInstructor.create(course_id: us_history.id)
    assert_equal mr_turner, us_history.course_instructors.first
  end

  def test_courses_with_instructors_no_delete
    us_history = Course.create(name: "US History",course_code: 2451)
    mr_turner = CourseInstructor.create(course_id: us_history.id)
    assert_equal 1, Course.count
    us_history.destroy
    assert_equal 1, Course.count
  end

  def test_lessons_associated_courses
    us_history = Course.create(name: "US History", course_code: 2451)
    world_war_2 = Lesson.create(name: "World War 2", course_id: us_history.id)
    assert_equal 1, Course.count
    us_history.destroy
    assert_equal 0, Course.count
  end


  def test_readings_destroyed_with_lessons
    world_war_2 = Lesson.create(name: "World War 2")
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id)
    assert_equal 1, Lesson.count
    world_war_2.destroy
    assert_equal 0, Lesson.count
  end

  def test_lessons_readings_association
    world_war_2 = Lesson.create(name: "World War 2")
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id,order_number: 4,  url: "http://www.thebest.com")
    assert_equal american_involvement, world_war_2.readings.first
  end

  def test_course_association_with_readings
    us_history = Course.create(name: "US History", course_code: 2451)
    world_war_2 = Lesson.create(name: "World War 2", course_id: us_history.id)
    american_involvement = Reading.create(caption: "American Involvement", lesson_id: world_war_2.id, order_number: 4, url: "http://www.thebest.com")
    assert_equal american_involvement, us_history.readings.first
  end

  def test_school_must_have_name
    cedar_ridge = School.new({})
    refute cedar_ridge.save
    cedar_ridge = School.new(name: "Cedar Ridge")
    assert cedar_ridge.save
  end

  def test_terms_validation
    cedar_ridge = School.create(name: "Cedar Ridge")
    spring = Term.create({})
    fall = Term.create(name: "fall", starts_on: '2001-02-03', ends_on: '2001-05-04', school_id: cedar_ridge.id)
    assert fall.save
    refute spring.save
  end

end
