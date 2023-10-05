class OnlineStudentGradeController < ApplicationController
  def prepare
    year = params[:year]
    semester = params[:year]
    ids = Student.get_online_student(year, semester)
    crs = CourseRegistration.get_course_per_student(ids)
    result = StudentGrade.create_student_grade(crs)
    redirect_to admin_onlinestudentgrade_path, notice: "Student #{result.num_inserts} created"
  end
end
