class AssessmentPlan < ApplicationRecord
  # Validations
  validates :assessment_title, presence: true
  validates :assessment_weight, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
  validate :limit_assessment_plan

  # Associations
  belongs_to :course
  belongs_to :admin_user
  has_many :assessments

  private

  def limit_assessment_plan
    total_weight = self.course.assessment_plans.where(created_by: self.created_by).where.not(id: self.id).pluck(:assessment_weight).sum + self.assessment_weight
    if total_weight > 100
      errors.add(:assessment_weight, "The total assessment weight for your section cannot exceed 100.")
    end
  end
end
