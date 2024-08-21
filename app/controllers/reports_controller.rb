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

class ReportsController < ApplicationController
  before_action :authenticate_admin_user!

  def course_assignments
    # Fetch instructors with their course assignments
    @instructors = AdminUser.where(role: "instructor")
    
    # Fetch course-instructor assignments
    @course_instructors = CourseInstructor.joins(course: { program: :sections })
                                          .select('course_instructors.*, courses.course_title, courses.credit_hour, courses.ects, sections.id as section_id')
  end
end



