class AssessmensController < ApplicationController
  before_action { @disable_nav = true }

  def index
    course_id = params[:course_id]
    section_id = params[:section]
    current_admin_user = params[:current_admin_user]

    students = Student.includes(:course_registrations).where(section_id: section_id).map do |student|
      {
        id: student.id,
        first_name: student.first_name,
        middle_name: student.middle_name,
        last_name: student.last_name,
        year: student.year,
        semester: student.semester,
        student_id: student.student_id,
        course_registrations: student.course_registrations.map { |cr| { id: cr.id, course_id: cr.course_id } }
      }
    end

    assessment_plans = AssessmentPlan.where(course_id: course_id)

    render json: { student: students.to_json, assessment_plan: assessment_plans.to_json }
  end
  
  
  
  #def index
  #  course_id = params[:course_id]
  #  current_admin_user = params[:current_admin_user]
  #  section = CourseInstructor.where(admin_user_id: current_admin_user).where(course_id:).includes(:course).last.section
  #  #enrolled_students = CourseRegistration.where(enrollment_status: 'enrolled', course_id:, is_active: 'yes',
  #   #                                            section:).includes(:student).includes(:section).order('student_full_name ASC')
  #   enrolled_students = CourseRegistration.joins(:student).where(enrollment_status: 'enrolled', course_id:, is_active: 'yes'
  #   ).where("students.section_id=?", section.id).includes(:section).order('student_full_name ASC')
  #  assessment_plans = AssessmentPlan.where(course_id:, admin_user_id: current_admin_user)
  #  assessment_plans = assessment_plans.to_json(only: %i[id assessment_title assessment_weight])
  #  students = enrolled_students.to_json(only: [:id, :student_id], 
  #                                   include: { student: { only: %i[id first_name middle_name last_name year semester] }, 
  #                                              course: { only: %i[id] } })
  #  #students = enrolled_students.to_json(only: [:id],
  #  #                                     include: { student: { only: %i[
  #  #                                       id first_name year semester last_name
  #  #                                     ] }, course: { only: %i[id] } })
#
  #  respond_to do |format|
  #    format.json do
  #      render json: { student: students, assessment_plan: assessment_plans }
  #    end
  #  end
  #end

  def edit
    @assessment = Assessment.includes(:student).find(params[:id])
  end

  def update_mark
    assessment = Assessment.find_by(id: params[:id])
    assessment.value["#{params[:key]}"] = "#{params[:result]}"
    assessment.status = 0 if assessment.final_grade? || assessment.incomplete?
    if assessment.save!
      render json: { result: 'Updated', status: assessment }
    else
      render json: { result: assessment.errors.full_message, status: 'failed' }
    end
  end

  def create
    assessment = Assessment.where(student_id: search_params[:student_id], course_id: search_params[:course_id],
                                  admin_user_id: search_params[:admin_user_id], course_registration_id: search_params[:course_registration_id]).last
  
    if assessment.present?
      if assessment.value.key?("#{search_params[:assessment_title].split(' ').join('_')}")
        render json: { result: 'You already set mark for this assessment plan, please go to edit page if you want to edit!',
                       status: 'exist' }
      else
        assessment.value.merge!({ "#{search_params[:assessment_title].split(' ').join('_')}" => search_params[:result] })
        if assessment.save
          render json: { result: 'done', status: 'created' }
        else
          render json: { result: assessment.errors.full_messages, status: 'failed' }
        end
      end
    else
      assessment = Assessment.new(admin_user_id: search_params[:admin_user_id], student_id: search_params[:student_id],
                                  course_id: params[:course_id], course_registration_id: search_params[:course_registration_id], value: { "#{search_params[:assessment_title].split(' ').join('_')}" => search_params[:result] })
      if assessment.save!
        render json: { result: 'done', status: 'created' }
      else
        render json: { result: assessment.errors.full_messages, status: 'failed' }
      end
    end
  end
  

  def fetch_data
    students = Student.all.to_json
    assessment_plans = AssessmentPlan.all.to_json
  
    render json: { student: students, assessment_plan: assessment_plans }
  end
  
  # app/controllers/assessmens_controller.rb
def find_course
  admin_user_id = params[:current_admin_user]
  year = params[:year]
  semester = params[:semester]

  course_instructors = CourseInstructor.where(admin_user_id: admin_user_id, year: year, semester: semester)
  courses = Course.where(id: course_instructors.pluck(:course_id))
  programs = Program.where(id: courses.pluck(:program_id).uniq)

  result = courses.map do |course|
    {
      course: {
        id: course.id,
        course_title: course.course_title
      },
      program: programs.find { |p| p.id == course.program_id },
      sections: course.program.sections.map { |section| { id: section.id, name: section.section_full_name } }
    }
  end

  render json: result
end

  

  #def find_course
  #  year = params[:year]
  #  semester = params[:semester]
  #  current_admin_user = params[:current_admin_user]
  #
  #  course_instructors = CourseInstructor.where(admin_user_id: current_admin_user, year: year, semester: semester).includes(course: :program)
  #
  #  result = course_instructors.map do |ci|
  #    {
  #      course: {
  #        id: ci.course.id,
  #        course_title: ci.course.course_title
  #      },
  #      sections: ci.course.program.sections.map { |section| { id: section.id, name: section.section_full_name } }
  #    }
  #  end
  #
  #  Rails.logger.debug "Fetched courses and sections: #{result.inspect}"
  #
  #  respond_to do |format|
  #    format.json { render json: result }
  #  end
  #end
  
  
  
  private

  def search_params
    params.permit(:course_id, :student_id, :course_registration_id, :assessment_title, :result, :admin_user_id)
  end
end
