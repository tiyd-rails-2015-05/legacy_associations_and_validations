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

  def test_truth
    assert true
  end

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
end
