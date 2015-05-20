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
    spring = Term.create(name: "spring", school_id: ews.id)
    assert_equal spring, ews.terms.first
  end

  def test_term_course_association
    spring = Term.create(name: "spring")
    math = Course.create(name: "calc 2")
    assert_equal spring, ews.terms.first
  end
  
end
