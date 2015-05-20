class Reading < ActiveRecord::Base
  belongs_to :lesson
  after_destroy :log_destroy_action

  def log_destroy_action
    'Article destroyed'
  end
  
  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
