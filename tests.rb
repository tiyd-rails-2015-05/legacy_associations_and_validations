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

end
