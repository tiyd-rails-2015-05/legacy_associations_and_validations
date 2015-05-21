class Reading < ActiveRecord::Base
  belongs_to :lessons

  validates :url, format: {with: /\A(https?:\/\/)\w/i}, presence: true
  validates :order_number, presence: true
  validates :lesson_id, presence: true

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
