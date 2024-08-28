#class ReportsController < ApplicationController
#  before_action :authenticate_admin_user!
#
#  def course_assignments
#    if current_admin_user.role == "department head"
#      @instructors = AdminUser.joins(:course_instructors)
#                              .where(admin_users: { role: "instructor" })
#                              .select('admin_users.*, COUNT(course_instructors.id) as courses_count')
#                              .group('admin_users.id')
#    else
#      @instructors = AdminUser.where(role: "instructor")
#                              .select('admin_users.*, COUNT(course_instructors.id) as courses_count')
#                              .left_joins(:course_instructors)
#                              .group('admin_users.id')
#    end
#  end
#end

#class ReportsController < ApplicationController
#  before_action :authenticate_admin_user!
#
#  def course_assignments
#    # Fetch instructors with their course assignments
#    @instructors = AdminUser.where(role: "instructor")
#    
#    # Fetch course-instructor assignments
#    @course_instructors = CourseInstructor.joins(course: { program: :sections })
#                                          .select('course_instructors.*, courses.course_title, courses.credit_hour, courses.ects, sections.id as section_id')
#  end
#end

# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :authenticate_admin_user!

  def course_assignments
    @batches = Course.pluck(:batch).uniq
    @years = Course.pluck(:year).uniq
    @semesters = Course.pluck(:semester).uniq
    
    # Apply filtering based on selected batch, year, and semester
    @selected_batch = params[:batch]
    @selected_year = params[:year]
    @selected_semester = params[:semester]

    @instructors = AdminUser.where(role: "instructor")
    
    @course_instructors = CourseInstructor.joins(course: { program: :sections })
                                          .select('course_instructors.*, courses.course_title, courses.credit_hour, courses.ects, sections.id as section_id')
                                          .where(courses: { batch: @selected_batch, year: @selected_year, semester: @selected_semester })
  end

  def download_course_assignments
    @instructors = AdminUser.where(role: "instructor")
    @course_instructors = CourseInstructor.joins(course: { program: :sections })
                                          .select('course_instructors.*, courses.course_title, courses.credit_hour, courses.ects, sections.id as section_id')
                                          .where(courses: { batch: params[:batch], year: params[:year], semester: params[:semester] })

    respond_to do |format|
      format.pdf do
        pdf = InstructorLoadReportPdf.new(@instructors, @course_instructors)
        send_data pdf.render, filename: "instructor_load_report.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
end




