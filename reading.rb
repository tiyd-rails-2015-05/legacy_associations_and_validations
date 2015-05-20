class Reading < ActiveRecord::Base
  belongs_to :lesson

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  validates :order_number, presence: true
  validates :lesson_id, presence: true
  validates :url, presence: true

  def clone
    dup
  end
end
