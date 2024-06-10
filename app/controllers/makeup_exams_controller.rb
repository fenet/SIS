class MakeupExamsController < ApplicationController
    before_action :authenticate_student!

    def new
      @makeup_exam = MakeupExam.new
      @courses = CourseRegistration.where(student: current_student, enrollment_status: 'enrolled', semester: current_student.semester).includes(:course)
      #@courses = current_student.courses.where(semester: current_student.semester)
    end
  
    def create
      @makeup_exam = MakeupExam.new(makeup_exam_params)
      @makeup_exam.student = current_student
      @makeup_exam.academic_calendar = current_academic_calendar
      @makeup_exam.created_by = current_student.name.first
  
      if @makeup_exam.save
        redirect_to root_path, notice: "Makeup exam request submitted successfully."
      else
        @courses = current_student.courses.where(semester: current_student.semester)
        render :new
      end
    end
  
    private
  
    def makeup_exam_params
      params.require(:makeup_exam).permit(:course_id, :reason, :year, :semester)
    end
  
    def current_academic_calendar
      AcademicCalendar.current # Assuming you have a method to get the current academic calendar
    end
end
