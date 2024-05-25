ActiveAdmin.register Assessment do
  permit_params :student_id, :course_id, :student_grade_id, :assessment_plan_id, :result, :created_by, :updated_by, :final_exam

  scope :assessment_by_instructor, default: true, if: proc { current_admin_user.role == 'instructor' }
  scope :approved_by_instructor, if: proc {
                                       current_admin_user.role == 'department head' || current_admin_user.role == 'dean'
                                     }
  scope :approved_by_head, default: true, if: proc { current_admin_user.role == 'dean' }
  scope :incomplete_student
  scope :graded

  batch_action :approve_assessment_for, confirm: 'Are you sure?' do |ids|
    if current_admin_user.role == 'instructor'
      approve_accounter = 0
      incomplete_accounter = 0

      assessments = Assessment.where(id: ids, admin_user_id: current_admin_user.id,
                                     status: 0).includes(:student).includes(:course)

      assessments.map do |assessment|
        if assessment.value.keys.size == assessment.course.assessment_plans.size
          assessment.update(status: 1)
          approve_accounter += 1
        else
          assessment.update(status: 4)
          incomplete_accounter += 1
        end
      end
      redirect_to admin_assessments_path,
                  notice: "#{approve_accounter} #{'student'.pluralize(approve_accounter)} assessment approved and #{incomplete_accounter} #{'student'.pluralize(incomplete_accounter)} got incomplete "
    elsif current_admin_user.role == 'department head'
      approve_accounter = 0
      incomplete_accounter = 0

      assessments = Assessment.includes(:student, :course).where(id: ids, status: 1,
                                                                 student: { department_id: current_admin_user.department_id })
      assessments.map do |assessment|
        if assessment.value.keys.size == assessment.course.assessment_plans.size
          assessment.update(status: 2)
          approve_accounter += 1
        else
          assessment.update(status: 4)
          incomplete_accounter += 1
        end
      end
      redirect_to admin_assessments_path,
                  notice: "#{approve_accounter} #{'student'.pluralize(approve_accounter)} assessment approved and #{incomplete_accounter} #{'student'.pluralize(incomplete_accounter)} got incomplete "
    elsif current_admin_user.role == 'dean'
      success_counter = 0
      error_counter = 0

      assessments = Assessment.where(id: ids, status: 2).includes(:student).includes(:course)
      assessments.each do |assessment|
        total = Assessment.total_mark(assessment.value)
        grade = Assessment.get_letter_grade(total)
        f_counter = if grade.first == 'F'
                      1
                    else
                      0

                    end
        student_grade = StudentGrade.new(student_id: assessment.student_id, course_id: assessment.course_id,
                                         course_registration_id: assessment.course_registration_id,
                                         department_id: assessment.student.department_id, program_id:
                                           assessment.student.program_id, letter_grade: grade.first, assesment_total:
                                           total, grade_point: grade.last, f_counter:)
        if student_grade.save
          assessment.update(status: 5)
          success_counter += 1
        else
          error_counter += 1
        end
      end
      redirect_to admin_assessments_path,
                  notice: "#{success_counter} #{'student'.pluralize(success_counter)} student grade generated and #{error_counter} #{'student'.pluralize(error_counter)} failed to generate grade "

    end
  end

  index do
    selectable_column
    column 'Student', sortable: true do |n|
      "#{n.student.first_name}"
    end

    column 'Course', sortable: true do |c|
      c.course.course_title
    end

    column 'Assessment', width: '40%' do |c|
      total = 0
      columns class: 'assessments', width: '100%' do
        c.value.each do |val|
          data = val
          total += data.last.to_i
          column class: 'assessment-result', width: '100%' do
            div style: 'display: block; width: 100%; margin-bottom: 10px;' do
              span "#{data.first} = #{data.last}"
            end
          end
        end
        column class: 'assessment-result', width: '100%' do
          div style: 'display: block; width: 100%; margin-bottom: 10px;' do
            span "Total = #{total}"
          end
        end
        br
        column width: '100%' do
          div style: 'display: block; width: 100%; margin-bottom: 10px;' do
            link_to 'Edit', edit_assessmen_path(c), target: '_blank'
          end
        end
      end
    end
  

    column 'left', sortable: true do |c|
      span(c.course.assessment_plans.count - c.value.size)
    end

  
    actions
  end

  form do |_f|
    years = CourseInstructor.where(admin_user: current_admin_user).distinct.pluck(:year)
    render 'assessment/new', { years: }
  end
end





#ActiveAdmin.register Assessment do
#  # See permitted parameters documentation:
#  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#  #
#  # Uncomment all parameters which should be permitted for assignment
#  #
#  permit_params :student_id, :course_id, :student_grade_id, :assessment_plan_id, :result, :created_by, :updated_by,
#                :final_exam
#  #
#  # or
#  #
#  # permit_params do
#  #   permitted = [:student_id, :course_id, :student_grade_id, :assessment_plan_id, :result, :created_by, :updated_by, :final_exam]
#  #   permitted << :other if params[:action] == 'create' && current_user.admin?
#  #   permitted
#  # end
#  scope :assessment_by_instructor, default: true, if: proc { current_admin_user.role == 'instructor' }
#  scope :approved_by_instructor, if: proc {
#                                       current_admin_user.role == 'department head' || current_admin_user.role == 'dean'
#                                     }
#  scope :approved_by_head, default: true, if: proc { current_admin_user.role == 'dean' }
#  scope :incomplete_student
#  scope :graded
#  #  if: proc { current_admin_user.role == 'dean' }
#
#  batch_action :approve_assessment_for, confirm: 'Are you sure?' do |ids|
#    if current_admin_user.role == 'instructor'
#      approve_accounter = 0
#      incomplete_accounter = 0
#
#      assessments = Assessment.where(id: ids, admin_user_id: current_admin_user.id,
#                                     status: 0).includes(:student).includes(:course)
#
#      assessments.map do |assessment|
#        if assessment.value.keys.size == assessment.course.assessment_plans.size
#          assessment.update(status: 1)
#          approve_accounter += 1
#        else
#          assessment.update(status: 4)
#          incomplete_accounter += 1
#        end
#      end
#      redirect_to admin_assessments_path,
#                  notice: "#{approve_accounter} #{'student'.pluralize(approve_accounter)} assessment approved and #{incomplete_accounter} #{'student'.pluralize(incomplete_accounter)} got incomplete "
#    elsif current_admin_user.role == 'department head'
#      approve_accounter = 0
#      incomplete_accounter = 0
#
#      assessments = Assessment.includes(:student, :course).where(id: ids, status: 1,
#                                                                 student: { department_id: current_admin_user.department_id })
#      assessments.map do |assessment|
#        if assessment.value.keys.size == assessment.course.assessment_plans.size
#          assessment.update(status: 2)
#          approve_accounter += 1
#        else
#          assessment.update(status: 4)
#          incomplete_accounter += 1
#        end
#      end
#      redirect_to admin_assessments_path,
#                  notice: "#{approve_accounter} #{'student'.pluralize(approve_accounter)} assessment approved and #{incomplete_accounter} #{'student'.pluralize(incomplete_accounter)} got incomplete "
#    elsif current_admin_user.role == 'dean'
#      success_counter = 0
#      error_counter = 0
#
#      assessments = Assessment.where(id: ids, status: 2).includes(:student).includes(:course)
#      assessments.each do |assessment|
#        total = Assessment.total_mark(assessment.value)
#        grade = Assessment.get_letter_grade(total)
#        f_counter = if grade.first == 'F'
#                      1
#                    else
#                      0
#
#                    end
#        student_grade = StudentGrade.new(student_id: assessment.student_id, course_id: assessment.course_id,
#                                         course_registration_id: assessment.course_registration_id,
#                                         department_id: assessment.student.department_id, program_id:
#                                           assessment.student.program_id, letter_grade: grade.first, assesment_total:
#                                           total, grade_point: grade.last, f_counter:)
#        if student_grade.save
#          assessment.update(status: 5)
#          success_counter += 1
#        else
#          error_counter += 1
#        end
#      end
#      redirect_to admin_assessments_path,
#                  notice: "#{success_counter} #{'student'.pluralize(success_counter)} student grade generated and #{error_counter} #{'student'.pluralize(error_counter)} failed to generate grade "
#
#    end
#  end
#  index do
#    selectable_column
#    column 'Student', sortable: true do |n|
#      "#{n.student.first_name.upcase} #{n.student.middle_name.upcase} #{n.student.last_name.upcase}"
#    end
#
#    column 'Student year' do |c|
#      c.student.year
#    end
#    column 'Student semester' do |c|
#      c.student.semester
#    end
#    column 'Course', sortable: true do |c|
#      c.course.course_title
#    end
#
#    column 'Assessment', width: '100%' do |c|
#      total = 0
#      columns class: 'assessments' do
#        c.value.each do |val|
#          data = val
#          total += data.last.to_i
#          column class: 'assessment-result' do
#            span "#{data.first} = #{data.last}"
#          end
#        end
#        column class: 'assessment-result' do
#          span "Total mark= #{total}"
#        end
#        column do
#          link_to 'Edit mark', edit_assessmen_path(c), target: '_black'
#        end
#      end
#    end
#    column 'Total assessment' do |c|
#      span c.course.assessment_plans.count
#    end
#    column 'Assessment left' do |c|
#      span(c.course.assessment_plans.count - c.value.size)
#    end
#    column :created_by
#    column :updated_by
#    column 'Status' do |c|
#      status_tag c.status
#    end
#
#    column 'Created At', sortable: true do |c|
#      c.created_at.strftime('%b %d, %Y')
#    end
#    actions
#  end
#
#  form do |_f|
#    years = CourseInstructor.where(admin_user: current_admin_user).distinct.pluck(:year)
#    render 'assessment/new', { years: }
#  end
#end
#