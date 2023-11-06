class Exemption < ApplicationRecord
  belongs_to :external_transfer
  enum :dean_approval_status, {
    dean_approval_pending: 0,
    dean_approval_approved: 1,
    dean_approval_rejected: 2,
  }

  enum :registeral_approval_status, {
         registeral_approval_pending: 0,
         registeral_approval_approved: 1,
         registeral_approval_rejected: 2,
       }
end
