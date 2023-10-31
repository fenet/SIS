class ExternalTransfer < ApplicationRecord
  belongs_to :department
  has_many :exemptions
  has_one_attached :transcript, dependent: :destroy
  validates :previous_student_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2,
  }
end
