class SectionsController < ApplicationController
  before_action { @disable_nav = true }

  def index
      @programs = Program.select(:id, :program_name)
       @students  = Student.no_assigned.where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:program) unless params[:program].nil?
       @sections = Section.empty.or(Section.partial).where(program_id: params[:program][:name], year: params[:year], semester: params[:semester], batch: params[:student][:batch]).includes(:students) unless params[:program].nil?
     end

  def new
  end

  def create
     section_id = params[:section]
     section = Section.find(section_id)
     capacity = section.total_capacity - section.students.count
     @students = Student.no_assigned.where(program: section.program, year: section.year, semester: section.semester, batch: section.batch).includes(:program).limit(capacity)
     if @students.update(section_id: section.id, section_status: 1)
      if section.students.count < section.total_capacity
        section.partial!
      else
        section.full!
      end
      redirect_to assign_sections_path, notice: "#{section.students.count} students got assigned to #{section.section_full_name}"
     else
      redirect_to assign_sections_path, alert: "Something went wrong, please try again later"
     end

  end
end
