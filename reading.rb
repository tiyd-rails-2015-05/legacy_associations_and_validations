class Reading < ActiveRecord::Base

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  # VV MY CODE VV
  belongs_to :lesson
  has_one :course, through: :lesson

  def clone
    dup
  end
end
