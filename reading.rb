class Reading < ActiveRecord::Base
  belongs_to :lesson
  validates :order_number, presence: true
  validates :lesson_id, presence: true
  validates :url, presence: true
  validates :url, format: { with: /https?:\/\//i, on: :create }

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
