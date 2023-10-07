class ImportOnlineStudentGradeJob < ApplicationJob
  queue_as :default #set the queue with the deafult queue 

  def perform(department, year, semester, status)
    # Do something later
    student_grades = StudentGrade.online_student_grade(department, year, semester, status)

  end
end
