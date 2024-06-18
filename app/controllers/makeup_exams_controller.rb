class MakeupExamsController < ApplicationController
  before_action :authenticate_student!

  def new
    @makeup_exam = MakeupExam.new
    @courses = CourseRegistration.where(student: current_student, enrollment_status: 'enrolled', semester: current_student.semester).includes(:course)
  end

  def create
    @makeup_exam = MakeupExam.new(makeup_exam_params)
    @makeup_exam.student = current_student
    @makeup_exam.academic_calendar = current_student.academic_calendar
    @makeup_exam.year ||= current_student.year
    @makeup_exam.semester ||= current_student.semester
    @makeup_exam.created_by = current_student.first_name # Assuming `first_name` is available as `name.first` was not defined

    if params[:makeup_exam][:course_registration_id].present?
      course_registration = CourseRegistration.find(params[:makeup_exam][:course_registration_id])
      course = course_registration.course

      @makeup_exam.course_id = course.id
      @makeup_exam.program_id = course.program_id
      @makeup_exam.department_id = course.program.department_id
      @makeup_exam.course_registration_id = course_registration.id
      student_grade = StudentGrade.find_by(student: current_student, course_id: course.id)
      @makeup_exam.student_grade_id = student_grade.id if student_grade
      @makeup_exam.previous_result_total = student_grade.assessment_total if student_grade
      @makeup_exam.previous_letter_grade = student_grade.letter_grade if student_grade
    else
      flash[:alert] = "Course selection is required."
      @courses = CourseRegistration.where(student: current_student, enrollment_status: 'enrolled', semester: current_student.semester).includes(:course)
      render :new and return
    end

    if @makeup_exam.save
      redirect_to root_path, notice: "Makeup exam request submitted successfully."
    else
      @courses = CourseRegistration.where(student: current_student, enrollment_status: 'enrolled', semester: current_student.semester).includes(:course)
      render :new
    end
  end

  private

  def makeup_exam_params
    params.require(:makeup_exam).permit(:course_registration_id, :reason, :year, :semester, :attachment)
  end
end
