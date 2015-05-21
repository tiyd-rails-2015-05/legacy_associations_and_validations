
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'
require './migration'
require './application'


ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)


begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


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


  def test_01_lessons_associates_with_readings
    biology = Lesson.create(name: "Biology")
    chemistry = Lesson.create(name: "Chemistry")
    evolution = Reading.create(lesson_id: biology.id, url: "https://time.com", order_number: 2)
    big_band = Reading.create(lesson_id: biology.id, url: "https://time.com", order_number: 3)
    atoms = Reading.create(lesson_id: chemistry.id, url: "https://time.com", order_number: 1)

    assert_equal 2, biology.readings.count
    assert_equal 1, evolution.lesson_id
    assert_equal 2, atoms.lesson_id
  end

  def test_02_courses_associates_with_lessons
    fifth = Course.create(name: "Fifth", course_code: "SCI40")
    sixth = Course.create(name: "Sixth", course_code: "SCI30")
    biology = Lesson.create(name: "Biology", course_id: fifth.id)
    chemistry = Lesson.create(name: "Chemistry", course_id: fifth.id)
    geometry = Lesson.create(name: "Geometry", course_id: sixth.id)

    assert_equal 2, fifth.lessons.count
    assert_equal 1, biology.course_id
    assert_equal 2, geometry.course_id
  end

  def test_03_courses_instructors_associates_with_courses
    course1 = Course.create(name: "Course1", course_code: "ACT1")
    course2 = Course.create(name: "Course2", course_code: "DEV2")
    susan = CourseInstructor.create(course_id: course2.id)
    jimmy = CourseInstructor.create(course_id: course1.id)
    lisa = CourseInstructor.create(course_id: course2.id)


    assert_equal 2, course2.course_instructors.count
    assert_equal 1, jimmy.course_id
    assert_equal 2, susan.course_id
  end

  def test_04_lessons_associates_with_in_class_assignments
    course1 = Course.create(name: "Course1", course_code: "ACT1")
    assignment1 = Assignment.create(course_id: course1.id, name: "Classwork", percent_of_grade: 0.89)
    assignment2 = Assignment.create(course_id: course1.id, name: "Classwork2", percent_of_grade: 0.89)
    biology = Lesson.create(name: "Biology", course_id: course1.id, in_class_assignment_id: assignment2.id)
    chemistry = Lesson.create(name: "Chemistry", course_id: course1.id, in_class_assignment_id: assignment1.id)

    assert_equal 1, chemistry.in_class_assignments.id
    assert_equal 2, biology.in_class_assignments.id
  end

  def test_04_readings_destroy_with_lessons
    biology = Lesson.create(name: "Biology", course_id: "course1")
    evolution = Reading.create(lesson_id: biology.id, order_number: 1, url: "http://igotyou.com")
    big_band = Reading.create(lesson_id: biology.id, order_number: 1, url: "http://igotyou.com")

    assert_equal 2, biology.readings.count
    biology.destroy.save
    refute evolution
  end

  def test_05_lessons_destroy_with_courses
    course1 = Course.create(name: "Course1", course_code: "ACT1")
    biology = Lesson.create(name: "Biology", course_id: course1.id)

    assert_equal 1, course1.lessons.count
    course1.destroy.save
    refute biology
  end

  def test_06_schools_must_have_name
    sanderson = School.new(name: "Sanderson High")
    blank = School.new({})

    assert sanderson.save
    refute blank.save
  end

  def test_07_terms_must_have_name
    third = Term.new(name: "Third", starts_on: 2015-01-05, ends_on: 2015-03-30, school_id: 3)
    second = Term.new(starts_on: 2014-11-01, ends_on: 2015-01-01, school_id: 4)

    assert third.save
    refute second.save
  end

  def test_08_terms_have_starts_on
    fourth = Term.new(name: "Fourth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1 )
    second = Term.new(name: "Second", ends_on: 2015-01-01, school_id: 2)

    assert fourth.save
    refute second.save
  end

  def test_09_terms_have_ends_on
    fifth = Term.new(name: "Fifth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1)
    second = Term.new(name: "Second", starts_on: 2014-10-11, school_id: 2)

    assert fifth.save
    refute second.save
  end

  def test_09_terms_have_school_id
    sixth = Term.new(name: "sixth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1)
    second_time = Term.new(name: "Second", starts_on: 2014-10-11, ends_on: 2015-01-02)

    assert sixth.save
    refute second_time.save
  end

  def test_10_user_have_first_name
    adam = User.new(first_name: "Adam", last_name: "Scott", email: "adams@yahoo.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(last_name: "Harrison", email: "sue@yahoo.com", photo_url: "http://yougotmyphoto.com")

    assert adam.save
    refute sue.save
  end

  def test_11_user_have_last_name
    sam = User.new(first_name: "Sam", last_name: "Adams", email: "sadams@gmail.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(first_name: "Sue", email: "sue@yahoo.com", photo_url: "http://yougotmyphoto.com")

    assert sam.save
    refute sue.save
  end

  def test_12_user_have_email
    joe = User.new(first_name: "Joe", last_name: "Adams", email: "jadams@gmail.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(first_name: "Sue", last_name: "Harris", photo_url: "http://yougotmyphoto.com")

    assert joe.save
    refute sue.save
  end

  def test_13_user_have_unique_email
    brad = User.new(first_name: "Brad", last_name: "Adams", email: "badams@gmail.com", photo_url: "http://yougotmyphoto.com")
    helen = User.new(first_name: "Helen", last_name: "Harris", email: "badams@gmail.com", photo_url: "http://yougotmyphoto.com")

    assert brad.save
    refute helen.save
  end

  def test_14_user_has_correctly_formatted_email
    trent = User.new(first_name: "Trent", last_name: "Adams", email: "adams@gmail.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(first_name: "Sue", last_name: "James", email: "sue@yahoo3.com", photo_url: "http://yougotmyphoto.com")
    kate = User.new(first_name: "Kate", last_name: "Harris", email: "kate.gmail.com", photo_url: "http://yougotmyphoto.com")
    erica = User.new(first_name: "Erica", last_name: "Jackson", email: "ejackson4@yahoocom", photo_url: "http://yougotmyphoto.com")
    cash = User.new(first_name: "Cash", last_name: "Price", email: "cash@yahoo3.co", photo_url: "http://yougotmyphoto.com")

    assert trent.save
    assert sue.save
    refute kate.save
    refute erica.save
    refute cash.save
  end

  def test_15_user_has_correctly_formatted_url_photo
    allen = User.new(first_name: "Allen", last_name: "Heems", email: "aheems@gmail.com", photo_url: "http://yougotmyphoto.com")
    scar = User.new(first_name: "Scar", last_name: "James", email: "scar@yahoo.com", photo_url: "https://ihaveyourphoto.com")
    slate = User.new(first_name: "Slate", last_name: "Harris", email: "slate@gmail.com", photo_url: "htps://thisisnotaurl.com")
    bob = User.new(first_name: "Bob", last_name: "Harris", email: "bob@gmail.com", photo_url: "shttps://thisisnotaurl.com")

    assert allen.save
    assert scar.save
    refute slate.save
    refute bob.save
  end

  def test_16_assignment_has_course_id
    project = Assignment.new(course_id: 2, name: "Project", percent_of_grade: 0.76)
    weekend_project = Assignment.new(name: "Weekend Project", percent_of_grade: 0.96)

    assert project.save
    refute weekend_project.save
  end

  def test_17_assignment_has_name
    project1 = Assignment.new(course_id: 1, name: "Project1", percent_of_grade: 0.88)
    weekend_project1 = Assignment.new(course_id: 2, percent_of_grade: 0.90)

    assert project1.save
    refute weekend_project1.save
  end

  def test_18_assignment_has_percent_of_grade
    project2 = Assignment.new(course_id: 1, name: "Project2", percent_of_grade: 0.50)
    weekend_project2 = Assignment.new(course_id: 2, name: "Weekend Project2")

    assert project2.save
    refute weekend_project2.save
  end

  def test_19_assignment_name_unique_to_course_id
    me = Assignment.new(course_id: 1, name: "Me", percent_of_grade: 0.90)
    myself = Assignment.new(course_id: 2, name: "Me", percent_of_grade: 0.75)
    you = Assignment.new(course_id: 1, name: "Me", percent_of_grade: 0.88)

    assert me.save
    assert myself.save
    refute you.save
  end

#why did this break
  def test_20_term_can_not_be_destroyed_if_courses_present
    fall_term = Term.create(name: "Fall")
    course = Course.create(name: "Marching Band", course_code: "MUSC 3000", term_id: fall_term.id)

    refute fall_term.destroy
  end

#why did this break
  def test_21_course_can_not_be_destroyed_if_course_students_present
    band_course = Course.create(name: "Marching Band", course_code: "MUSC 3000")
    students = CourseStudent.create(student_id: 1, course_id: band_course.id)

    refute band_course.destroy
  end

#breaking because of random runs, dont know why
  def test_assignments_are_destroyed_when_courses_are_destroyed
    band_course = Course.create(name: "Marching Band")
    assignment = Assignment.create(name: "Malaguena", course_id: band_course.id )

    band_course.destroy
    assert_equal 0 , Assignment.count
  end

  def test_stupid_one
   scales = Lesson.create(name: "Scales")
   pre = Assignment.create(name: "Read Book")
   Lesson.linked_to_assignment(pre)
   scales.update(pre_class_assignment_id: pre.id)

   assert scales.save
   assert_equal pre.id, scales.pre_class_assignment_id
 end


  def test_school_set_up
    uw = School.create(name: "University of Wyoming")
    fall_term = Term.create(name: "Fall", school_id: uw.id)
    band_course = Course.create(name: "Marching Band", course_code: "MUSC 3000", term_id: fall_term.id)
    theory_course = Course.create(name: "Music Theory", course_code: "MUSC 1050", term_id: fall_term.id)

    spring_term = Term.create(name: "Spring", school_id: uw.id)
    jazz_course = Course.create(name: "Jazz Band", course_code: "MUSC 2500", term_id: spring_term.id)
    symphony_course = Course.create(name: "Wind Symphony", course_code: "MUSC 4500", term_id: spring_term.id)

    assert uw
    assert fall_term
    assert band_course
    assert theory_course
    assert spring_term
    assert jazz_course
    assert symphony_course
  end

  def test_lessons_have_name
    scales =  Lesson.create(name: "Scales")

    assert scales
  end

  def test_reading_has_url_order_number_and_lesson_id
    read =  Reading.new(order_number: 1, url:"https://String", lesson_id: 1)

    assert read.save
  end

  def test_readings_start_with_proper_syntax
    read =  Reading.new(order_number: 1, url:"https://String", lesson_id: 1)

    assert read.save
  end

  def test_course_has_code_and_name
    band_course = Course.new(name: "Marching Band", course_code: "MUSC 3000")
    jazz_course = Course.new(name: "Jazz Band", course_code: "MUSC 3000")
    theory_course = Course.new(name: "Music Theory", course_code: "MUSC 1050")

    assert band_course.save
    assert theory_course.save
    refute jazz_course.save
  end

end
