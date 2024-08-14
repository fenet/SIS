class CoursesController < ApplicationController
    def index
        @courses = Course.includes(:program, :curriculum).where(program: current_student.program, curriculum: current_student.program.curriculums, year: current_student.year, semester: current_student.semester)
      end
    
      # Other actions can be added here (show, new, edit, create, update, destroy)
    
      private
    
      def set_course
        @course = Course.find(params[:id])
      end
    
      def course_params
        params.require(:course).permit(:course_module_id, :curriculum_id, :program_id, :course_title, :course_code, :course_description, :year, :semester, :course_starting_date, :course_ending_date, :credit_hour, :lecture_hour, :lab_hour, :ects, :created_by, :last_updated_by, :major)
      end
end
