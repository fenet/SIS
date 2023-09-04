class GradeReport < ApplicationRecord

	##validations
  	validates :admission_type, :presence => true
		validates :study_level, :presence => true
		validates :total_course, :presence => true
		validates :total_credit_hour, :presence => true
		validates :total_grade_point, :presence => true
		validates :cumulative_total_credit_hour, :presence => true
		validates :cumulative_total_grade_point, :presence => true
		validates :cgpa, :presence => true
		validates :sgpa, :presence => true
		validates :semester, :presence => true
		validates :year, :presence => true
		validates :academic_status, :presence => true
  ##associations
 	  belongs_to :department
	  belongs_to :semester_registration
	  belongs_to :student
	  belongs_to :academic_calendar
	  belongs_to :program
	  belongs_to :section, optional: true
end
