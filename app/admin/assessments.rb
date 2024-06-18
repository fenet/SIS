ActiveAdmin.register Assessment do
  permit_params :student_id, :course_id, :student_grade_id, :assessment_plan_id, :result, :created_by, :updated_by, :final_exam, :course_registration_id

  # Custom Filters
  filter :student_id, label: 'Student', as: :select, collection: proc { Student.all.map { |student| ["#{student.first_name} #{student.last_name}", student.id] } }
  #filter :course, collection: proc { Course.all.map { |course| [course.course_title, course.id] } }
  #filter :course, as: :select, collection: proc {
  #  Course.instructor_courses(current_admin_user.id).map { |course| [course.course_title, course.id] }
  #}
  filter :course_program_id, as: :select, label: 'Program', collection: proc { Program.all.map { |program| [program.program_name, program.id] } }

  # Define scopes and batch actions
  scope :assessment_by_instructor, default: true, if: proc { current_admin_user.role == 'instructor' }
  scope :approved_by_instructor, if: proc { current_admin_user.role == 'department head' || current_admin_user.role == 'dean' }
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
    # Columns
    selectable_column
    column 'Student', sortable: true do |n|
      "#{n.student.first_name} #{n.student.middle_name} #{n.student.last_name}"
    end
  
    column 'Course', sortable: true do |c|
      c.course.course_title
    end
  
   # column 'Assessment', width: '40%' do |c|
   #   total = 0
   #   columns class: 'assessments', width: '100%' do
   #     c.value.each do |val|
   #       data = val
   #       total += data.last.to_i
   #       column class: 'assessment-result', width: '100%' do
   #         div style: 'display: block; width: 100%; margin-bottom: 10px;' do
   #           span "#{data.first} = #{data.last}"
   #         end
   #       end
   #     end
   #   end
   # end
  
    column 'Remaining Assessment', sortable: true do |c|
      span(c.course.assessment_plans.count - c.value.size)
    end
  
    column 'Total', width: '20%' do |c|
      total = c.value.map(&:last).map(&:to_i).sum
      div style: 'display: block; margin-bottom: 10px;' do
        span "Sum = #{total}"
      end
      div style: 'display: block;' do
        link_to 'Edit', edit_assessmen_path(c), class: 'button', target: '_blank'
      end
    end

    column 'Letter Grade', width: '20%' do |c|
      total = c.value.map(&:last).map(&:to_i).sum
      grade = Assessment.get_letter_grade(total)
      div style: 'display: block; margin-bottom: 10px;' do
        span "#{grade.first}"
      end
    end
  
    actions
  end
  

  form do |_f|
    years = CourseInstructor.where(admin_user: current_admin_user).distinct.pluck(:year)
    sections = Section.all # Fetch all sections or filter based on criteria
    render 'assessment/new', { years:, sections: }
    #render 'assessment/new', { years: }
  end

 # csv do
 #   column('Student') { |assessment| "#{assessment.student.first_name} #{assessment.student.middle_name} #{assessment.student.last_name}" }
 #   column('Course') { |assessment| assessment.course.course_title }
#
 #   # Include each unique assessment key as a column for the specific course
 #   assessment_columns = ->(assessment) { Assessment.csv_columns_for_course(assessment.course_id) }
 #   
 #   # For each assessment key, add a column to the CSV
 #   assessment_columns.call(resource).each do |key|
 #     column(key) { |assessment| assessment.value[key] }
 #   end
#
 #   column('Total') { |assessment| assessment.value.map(&:last).map(&:to_i).sum }
 #   column('Grade') { |assessment| Assessment.get_letter_grade(assessment.value.map(&:last).map(&:to_i).sum).first }
 # end

  # Add a custom action item to download the CSV file
  action_item :download_csv, only: :index do
    link_to 'Download CSV', admin_assessments_path(format: :csv)
  end

end



