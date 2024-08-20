class CoursesController < ApplicationController
    def index
        @courses = Course.includes(:program, :curriculum).where(program: current_student.program, curriculum: current_student.program.curriculums, year: current_student.year, semester: current_student.semester)
      end
    
      # Other actions can be added here (show, new, edit, create, update, destroy)

      def pdf_by_scope
        scope = params[:scope]
        courses = filtered_courses(scope)
    
        pdf = CoursesPdf.new(courses)
    
        send_data pdf.render, filename: "courses_#{scope}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    
      private

      #def filtered_courses(scope)
      #  case scope
      #  when 'regular_year_1_semester_1'
      #    Course.joins(:program).where(year: 1, semester: 1, programs: { admission_type: 'regular' })
      #  when 'extension_year_1_semester_1'
      #    Course.joins(:program).where(year: 1, semester: 1, programs: { admission_type: 'extension' })
      #  # Add more cases for other scopes
      #  else
      #    Course.none
      #  end
      #end
    
      def set_course
        @course = Course.find(params[:id])
      end
    
      def course_params
        params.require(:course).permit(:course_module_id, :curriculum_id, :program_id, :course_title, :course_code, :course_description, :year, :semester, :course_starting_date, :course_ending_date, :credit_hour, :lecture_hour, :lab_hour, :ects, :created_by, :last_updated_by, :major)
      end
end
