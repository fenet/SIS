class AcademicCalendarsController < ApplicationController
  before_action :set_academic_calendar, only: %i[show]

  def index
    @academic_calendars = AcademicCalendar.where(admission_type: current_student.admission_type,
                                                 study_level: current_student.study_level)
  end

  def show
  end
   
  def download_pdf
    academic_calendar = AcademicCalendar.find(params[:id])
    pdf = AcademicCalendarPdfGenerator.new(academic_calendar).render
    send_data pdf, filename: "academic_calendar_#{academic_calendar.id}.pdf", type: 'application/pdf', disposition: 'inline'
  end
  
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_academic_calendar
    @academic_calendar = AcademicCalendar.find(params[:id])
  end
end
