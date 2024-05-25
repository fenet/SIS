class AssessmensController < ApplicationController
  before_action { @disable_nav = true }

  def index
    course_id = params[:course_id]
    current_admin_user = params[:current_admin_user]
    section = CourseInstructor.where(admin_user_id: current_admin_user).where(course_id:).includes(:course).last.section
    #enrolled_students = CourseRegistration.where(enrollment_status: 'enrolled', course_id:, is_active: 'yes',
     #                                            section:).includes(:student).includes(:section).order('student_full_name ASC')
     enrolled_students = CourseRegistration.joins(:student).where(enrollment_status: 'enrolled', course_id:, is_active: 'yes'
     ).where("students.section_id=?", section.id).includes(:section).order('student_full_name ASC')
    assessment_plans = AssessmentPlan.where(course_id:, admin_user_id: current_admin_user)
    assessment_plans = assessment_plans.to_json(only: %i[id assessment_title assessment_weight])
    students = enrolled_students.to_json(only: [:id],
                                         include: { student: { only: %i[
                                           id first_name year semester last_name
                                         ] }, course: { only: %i[id] } })

    respond_to do |format|
      format.json do
        render json: { student: students, assessment_plan: assessment_plans }
      end
    end
  end

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
    assesment = Assessment.where(student_id: search_params[:student_id], course_id: search_params[:course_id],
                                 admin_user_id: search_params[:admin_user_id]).last

    if assesment.present?
      if assesment.value.key?("#{search_params[:assessment_title].split(' ').join('_')}")
        render json: { result: 'You already set mark for this assesment plan, please got to edit page if you want to edit!',
                       status: 'exist' }
      else

        assesment.value.merge!({ "#{search_params[:assessment_title].split(' ').join('_')}" => search_params[:result] })
        if assesment.save
          render json: { result: 'done', status: 'created' }
        else
          render json: { result: assesment.errors.full_message, status: 'failed' }
        end
      end
    else
      assessment = Assessment.new(admin_user_id: search_params[:admin_user_id], student_id: search_params[:student_id],
                                  course_id: params[:course_id], course_registration_id: search_params[:course_registration_id], value: { "#{search_params[:assessment_title].split(' ').join('_')}" => search_params[:result] })
      if assessment.save!
        render json: { result: 'done', status: 'created' }
      else
        render json: { result: assessment.errors.full_message, status: 'failed' }
      end
    end
  end

  def find_course
    year = params[:year]
    semester = params[:semester]
    current_admin_user = params[:current_admin_user]
    course_instructor = CourseInstructor.where(admin_user: current_admin_user, year:, semester:).includes(:course)
    respond_to do |format|
      format.json do
        render json: course_instructor.to_json(only: [:id], include: { course: { only: %i[id course_title] } })
      end
    end
  end

  private

  def search_params
    params.permit(:course_id, :student_id, :course_registration_id, :assessment_title, :result, :admin_user_id)
  end
end
