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

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_schools_must_have_name
    sanderson = School.new(name: "Sanderson High")
    blank = School.new({})

    assert sanderson.save
    refute blank.save
  end

  def test_terms_must_have_name
    third = Term.new(name: "Third", starts_on: 2015-01-05, ends_on: 2015-03-30, school_id: 3)
    second = Term.new(starts_on: 2014-11-01, ends_on: 2015-01-01, school_id: 4)

    assert third.save
    refute second.save
  end

  def test_terms_have_starts_on
    fourth = Term.new(name: "Fourth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1 )
    second = Term.new(name: "Second", ends_on: 2015-01-01, school_id: 2)

    assert fourth.save
    refute second.save
  end

  def test_terms_have_ends_on
    fifth = Term.new(name: "Fifth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1)
    second = Term.new(name: "Second", starts_on: 2014-10-11, school_id: 2)

    assert fifth.save
    refute second.save
  end

  def test_terms_have_school_id
    sixth = Term.new(name: "sixth", starts_on: 2015-04-05, ends_on: 2015-07-01, school_id: 1)
    second_time = Term.new(name: "Second", starts_on: 2014-10-11, ends_on: 2015-01-02)

    assert sixth.save
    refute second_time.save
  end

  def test_user_have_first_name
    adam = User.new(first_name: "Adam", last_name: "Scott", email: "adams@yahoo.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(last_name: "Harrison", email: "sue@yahoo.com", photo_url: "http://yougotmyphoto.com")

    assert adam.save
    refute sue.save
  end

  def test_user_have_last_name
    sam = User.new(first_name: "Sam", last_name: "Adams", email: "sadams@gmail.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(first_name: "Sue", email: "sue@yahoo.com", photo_url: "http://yougotmyphoto.com")

    assert sam.save
    refute sue.save
  end

  def test_user_have_email
    joe = User.new(first_name: "Joe", last_name: "Adams", email: "jadams@gmail.com", photo_url: "http://yougotmyphoto.com")
    sue = User.new(first_name: "Sue", last_name: "Harris", photo_url: "http://yougotmyphoto.com")

    assert joe.save
    refute sue.save
  end

  def test_user_have_unique_email
    brad = User.new(first_name: "Brad", last_name: "Adams", email: "badams@gmail.com", photo_url: "http://yougotmyphoto.com")
    helen = User.new(first_name: "Helen", last_name: "Harris", email: "badams@gmail.com", photo_url: "http://yougotmyphoto.com")

    assert brad.save
    refute helen.save
  end

  def test_user_has_correctly_formatted_email
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

  def test_user_has_correctly_formatted_url_photo
    allen = User.new(first_name: "Allen", last_name: "Heems", email: "aheems@gmail.com", photo_url: "http://yougotmyphoto.com")
    scar = User.new(first_name: "Scar", last_name: "James", email: "scar@yahoo.com", photo_url: "https://ihaveyourphoto.com")
    slate = User.new(first_name: "Slate", last_name: "Harris", email: "slate@gmail.com", photo_url: "htps://thisisnotaurl.com")
    bob = User.new(first_name: "Bob", last_name: "Harris", email: "bob@gmail.com", photo_url: "shttps://thisisnotaurl.com")

    assert allen.save
    assert scar.save
    refute slate.save
    refute bob.save
  end


  def test_assignment_has_course_id
    project = Assignment.new(course_id: 2, name: "Project", percent_of_grade: 0.76)
    weekend_project = Assignment.new(name: "Weekend Project", percent_of_grade: 0.96)

    assert project.save
    refute weekend_project.save
  end

  def test_assignment_has_name
    project1 = Assignment.new(course_id: 1, name: "Project1", percent_of_grade: 0.88)
    weekend_project1 = Assignment.new(course_id: 2, percent_of_grade: 0.90)

    assert project1.save
    refute weekend_project1.save
  end

  def test_assignment_has_percent_of_grade
    project2 = Assignment.new(course_id: 1, name: "Project2", percent_of_grade: 0.50)
    weekend_project2 = Assignment.new(course_id: 2, name: "Weekend Project2")

    assert project2.save
    refute weekend_project2.save
  end
end
