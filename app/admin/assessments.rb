ActiveAdmin.register Assessment do
  permit_params :student_id, :course_id, :student_grade_id, :assessment_plan_id, :result, :created_by, :updated_by, :final_exam, :course_registration_id

  # Custom Filters
  filter :student_id, label: 'Student', as: :select, collection: proc { Student.all.map { |student| ["#{student.first_name} #{student.last_name}", student.id] } }
  #filter :course, collection: proc { Course.all.map { |course| [course.course_title, course.id] } }
  #filter :course, as: :select, collection: proc {
  #  Course.instructor_courses(current_admin_user.id).map { |course| [course.course_title, course.id] }
  #}
  #filter :course_id, as: :search_select_filter, url: proc { Course.instructor_courses(current_admin_user.id).map },
  #       fields: [:course_title, :id], display_name: 'course_title', minimum_input_length: 2,
  #       order_by: 'created_at_asc' 
  filter :course_id, as: :search_select_filter, 
       url: proc {
         # Assuming you have a route that takes the current user's ID and returns the relevant courses
         admin_courses_path(current_admin_user_id: current_admin_user.id) 
       },
       fields: [:course_title, :id], 
       display_name: 'course_title', 
       minimum_input_length: 2, 
       order_by: 'created_at_asc'

  filter :course_program_id, as: :select, label: 'Program', collection: proc { Program.all.map { |program| [program.program_name, program.id] } }
  filter :student_section_id, as: :select, label: 'Section', collection: proc { Section.all.map { |section| [section.section_full_name, section.id] } }
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
    
      assessments = Assessment.where(id: ids, admin_user_id: current_admin_user.id, status: 0)
                              .includes(:student, :course)
    
      assessments.each do |assessment|
        # Fetch assessment plans created by the current admin user
        instructor_assessment_plans = assessment.course.assessment_plans.where(admin_user_id: current_admin_user.id)
        
        # Calculate non-empty result count for the current instructor
        non_empty_result_count = assessment.result.values.flat_map(&:values).reject(&:blank?).count
    
        # Debug logs
        puts "Assessment ID: #{assessment.id}"
        puts "Instructor Assessment Plans Count: #{instructor_assessment_plans.count}"
        puts "Non-empty Result Count: #{non_empty_result_count}"
        puts "Assessment Result: #{assessment.result.inspect}"
        
        if instructor_assessment_plans.count == non_empty_result_count
          assessment.update(status: 1)
          approve_accounter += 1
          puts "Assessment ID #{assessment.id} marked as complete (status: 1)"
        else
          assessment.update(status: 4)
          incomplete_accounter += 1
          puts "Assessment ID #{assessment.id} marked as incomplete (status: 4)"
        end
      end
    
      flash[:notice] = "Assessments approved: #{approve_accounter}, Incomplete: #{incomplete_accounter}"
      redirect_to admin_assessments_path
  
    
                elsif current_admin_user.role == 'department head'
                  approve_accounter = 0
                  incomplete_accounter = 0
                  assessments = Assessment.includes(:student, :course)
                                          .where(id: ids, status: 1, student: { department_id: current_admin_user.department_id })
                
                  assessments.each do |assessment|
                    # Debugging: Log the keys of assessment.result
                    Rails.logger.info "Assessment Result Keys: #{assessment.result.keys.inspect}"
                    
                    # Collect only relevant instructor IDs based on specific assessment's result keys
                    instructor_ids = assessment.result.keys.map { |key| key.split('_').first }.uniq
                    
                    instructor_status = instructor_ids.map do |instructor_id|
                      # Fetching the instructor's specific assessment plans
                      instructor_assessment_plans = assessment.course.assessment_plans.where(admin_user_id: instructor_id)
                
                      # Debugging
                      Rails.logger.info "Instructor ID: #{instructor_id}"
                      Rails.logger.info "Assessment Plans Count: #{instructor_assessment_plans.count}"
                
                      # Adjusted logic to count non-empty result keys that match the instructor's assessment plans
                      non_empty_result_count = instructor_assessment_plans.count do |plan|
                        key = "#{instructor_id}_#{plan.assessment_title}"
                        !assessment.result[key].blank?
                      end
                
                      Rails.logger.info "Non-empty Result Keys Count: #{non_empty_result_count}"
                
                      assessment.result.each do |key, value|
                        Rails.logger.info "Result Key: #{key}, Value: #{value}"
                      end
                
                      # Determine completeness
                      if instructor_assessment_plans.count == non_empty_result_count
                        :complete
                      else
                        :incomplete
                      end
                    end
                
                    if instructor_status.include?(:incomplete)
                      assessment.update(status: 4)
                      incomplete_accounter += 1
                    else
                      assessment.update(status: 2)
                      approve_accounter += 1
                    end
                  end
                
                  flash[:notice] = "Assessments approved: #{approve_accounter}, Incomplete: #{incomplete_accounter}"
                  redirect_to admin_assessments_path
                
                
                
                
                   
              
  #elsif current_admin_user.role == 'department head'
  #  approve_accounter = 0
  #  incomplete_accounter = 0
  #
  #  # Log current admin user details
  #  Rails.logger.info "Current Admin User: #{current_admin_user.id}, Department ID: #{current_admin_user.department_id}"
  #
  #  assessments = Assessment.includes(:student, :course).where(id: ids, status: 1, student: { department_id: current_admin_user.department_id })
  #
  #  # Log the retrieved assessments count
  #  Rails.logger.info "Retrieved Assessments Count: #{assessments.size}"
  #
  #  assessments.each do |assessment|
  #    # Fetch assessment plans created by any instructor in the department
  #    department_instructor_ids = AdminUser.where(department_id: current_admin_user.department_id).pluck(:id)
  #    department_assessment_plans = assessment.course.assessment_plans.where(admin_user_id: department_instructor_ids)
  #
  #    # Log details for each assessment
  #    Rails.logger.info "Assessment ID: #{assessment.id}"
  #    Rails.logger.info "Department Assessment Plans Count: #{department_assessment_plans.count}"
  #    Rails.logger.info "Assessment Result Keys Size: #{assessment.result.keys.size}"
  #
  #    if department_assessment_plans.count == assessment.result.keys.size
  #      assessment.update(status: 2)
  #      approve_accounter += 1
  #    else
  #      assessment.update(status: 4)
  #      incomplete_accounter += 1
  #    end
  #  end
  #
  #  redirect_to admin_assessments_path,
  #              notice: "#{approve_accounter} #{'student'.pluralize(approve_accounter)} assessment approved and #{incomplete_accounter} #{'student'.pluralize(incomplete_accounter)} got incomplete. Check logs for details."

  
  
  
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
#


#



  index do
    # Columns
    selectable_column
    column 'Student', sortable: 'student.first_name' do |n|
      "#{n.student.first_name} #{n.student.middle_name} #{n.student.last_name}"
    end
  
    column 'Course', sortable: 'course.course_title' do |c|
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
  
    #column 'Remaining Assessment', sortable: true do |c|
    #  span(c.course.assessment_plans.count - c.value.size)
    #end
    column 'Remaining Assessment', sortable: true do |c|
      remaining_assessments = 0
    
      if current_admin_user.role == 'instructor'
        instructor_assessment_plans = c.course.assessment_plans.where(admin_user_id: current_admin_user.id)
        remaining_assessments = instructor_assessment_plans.count - c.value.size
      elsif current_admin_user.role == 'department head'
        department_instructor_ids = AdminUser.where(department_id: current_admin_user.department_id).pluck(:id)
        department_assessment_plans = c.course.assessment_plans.where(admin_user_id: department_instructor_ids)
        remaining_assessments = department_assessment_plans.count - c.value.size
      #else
       # remaining_assessments = c.course.assessment_plans.count - c.value.size
      end
    
      remaining_assessments = remaining_assessments < 0 ? 0 : remaining_assessments
    
      span(remaining_assessments)
    end
    
    
    column 'Total', width: '20%' do |c|
      total = c.value.map(&:last).map(&:to_f).sum
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

  controller do
    def scoped_collection
      super.joins(:student, :course)
    end
  end
end



