class AssessmentPlan < ApplicationRecord
  # Validations
  validates :assessment_title, presence: true
  validates :assessment_weight, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
  validate :limit_assessment_plan

  # Associations

  belongs_to :admin_user
  belongs_to :course

  has_many :assessments

  private

   def limit_assessment_plan
    return unless course_id.present? && assessment_weight.present?

    total_weight = course.assessment_plans
                       .where.not(id: id)
                       .pluck(:assessment_weight)
                       .compact
                       .sum

    if (total_weight + assessment_weight) > 100
      errors.add(:assessment_weight, "The total assessment weight for your section cannot exceed 100.")
    end
  end
  
end
