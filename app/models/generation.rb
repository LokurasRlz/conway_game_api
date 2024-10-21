class Generation < ApplicationRecord
  belongs_to :board

  validates :state, presence: true
  validates :step, presence: true
end
