class SectionsController < ApplicationController
  before_action { @disable_nav = true }
  before_action :set_section, only: [:download_pdf]

  def index
    @programs = Program.select(:id, :program_name)
    unless params[:program].nil?
      @students = Student.no_assigned.where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:program)
      @sections = Section.empty.or(Section.partial).where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:students)
    end
  end

  def download_pdf
    pdf = SectionPdfGenerator.new(@section).render
    send_data pdf, filename: "section_#{@section.id}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  def new
  end

  def create
    section_id = params[:section]
    student_ids = params[:student_ids]
    section = Section.find(section_id)

    if student_ids.present?
      students = Student.where(id: student_ids)

      students.each do |student|
        student.update(section_id: section.id, section_status: 1)
      end

      if section.students.count < section.total_capacity
        section.partial!
      else
        section.full!
      end

      redirect_to assign_sections_path, notice: "#{students.count} students assigned to #{section.section_full_name}"
    else
      redirect_to assign_sections_path, alert: "No students selected for assignment."
    end
  end


 private

  def set_section
    @section = Section.find(params[:id])
  end
end






#class SectionsController < ApplicationController
#  before_action { @disable_nav = true }
#
#  def index
#      @programs = Program.select(:id, :program_name)
#       @students  = Student.no_assigned.where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:program) unless params[:program].nil?
#       @sections = Section.empty.or(Section.partial).where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:students) unless params[:program].nil?
#     end
#
#  def new
#  end
#
#  def create
#     section_id = params[:section]
#     section = Section.find(section_id)
#     capacity = section.total_capacity - section.students.count
#     @students = Student.no_assigned.where(program: section.program, year: section.year, semester: section.semester, batch: section.batch).includes(:program).limit(capacity)
#     if @students.update(section_id: section.id, section_status: 1)
#      if section.students.count < section.total_capacity
#        section.partial!
#      else
#        section.full!
#      end
#      redirect_to assign_sections_path, notice: "#{section.students.count} students got assigned to #{section.section_full_name}"
#     else
#      redirect_to assign_sections_path, alert: "Something went wrong, please try again later"
#     end
#
#  end
#end
#