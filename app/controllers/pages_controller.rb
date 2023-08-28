class PagesController < ApplicationController
  before_action :authenticate_student!, only: [:enrollement, :documents, :profile, :dashboard, :create_semester_registration]
  # layout false, only: [:home]
  def home
    # authenticate_student!
  end

  def admission
  end

  def documents
  end

  def digital_iteracy_quiz
  end

  def requirement
  end

  def profile
    @address = current_student.student_address
    @emergency_contact = current_student.emergency_contact
  end

  def dashboard
    @address = current_student.student_address
    @emergency_contact = current_student.emergency_contact
    @invoice = Invoice.find_by(student: current_student, semester: current_student.semester, year: current_student.year)
    @smr = current_student.semester_registrations.where(year: current_student.year, semester: current_student.semester).last
  end

  def enrollement
    @total_course = current_student.program.curriculums.where(active_status: "active").first.courses.where(year: current_student.year, semester: current_student.semester).order("year ASC
      ", "semester ASC")
  end

  def create_semester_registration
    mode_of_payment = params[:mode_of_payment]
    total_course = params[:total_course]
    registration = SemesterRegistration.new
    registration.student_id = current_student.id
    registration.program_id = current_student.program.id
    registration.department_id = current_student.program.department.id
    registration.student_full_name = "#{current_student.first_name.upcase} #{current_student.middle_name.upcase} #{current_student.last_name.upcase}"
    registration.student_id_number = current_student.student_id
    registration.created_by = "#{current_student.created_by}"
    ## TODO: find the calender of student admission type and study level
    registration.academic_calendar_id = current_student.academic_calendar.id
    registration.year = current_student.year
    registration.semester = current_student.semester
    registration.program_name = current_student.program.program_name
    registration.admission_type = current_student.admission_type
    registration.study_level = current_student.study_level
    registration.created_by = current_student.last_updated_by
    registration.mode_of_payment = mode_of_payment
    registration.total_enrolled_course = total_course
    respond_to do |format|
      if registration.save
        format.html { redirect_to invoice_path(registration.invoices.last.id), notice: "Registration was successfully created." }
        format.json { render :show, status: :ok, location: registration }
      else
        format.html { redirect_to :enrollement_path, alert: "Something went wrong please try again" }
        format.json { render json: registration.errors, status: :unprocessable_entity }
      end
    end
  end
end
