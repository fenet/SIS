class StudentCopyController < ApplicationController
    add_flash_types :success
  def index
    @disable_nav =true
    @department = Department.select(:department_name, :id)
    @year = Student.distinct.select(:graduation_year).where.not(graduation_year: nil)
  end

  def generate_student_copy
    graduation_year = params[:year][:name]
    department_id = params[:department][:year]
    gc_date = params[:gc_date]
    students = Student.where(department_id: department_id).where(graduation_year: graduation_year).where(graduation_status: 'approved').includes(:grade_reports).includes(:student_grades).includes(:course_registrations)
    p "================="
    p students.size
  end
end
