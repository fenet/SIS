class ReportsController < ApplicationController
  before_action :authenticate_admin_user!

  def course_assignments
    if current_admin_user.role == "department head"
      department_head_name = "#{current_admin_user.first_name} #{current_admin_user.last_name}"
      @instructors = AdminUser.joins(:course_instructors)
                              .where(course_instructors: { created_by: department_head_name })
                              .where(admin_users: { role: "instructor" })
                              .select('admin_users.*, COUNT(course_instructors.id) as courses_count')
                              .group('admin_users.id')
    else
      @instructors = AdminUser.where(role: "instructor")
                              .select('admin_users.*, COUNT(course_instructors.id) as courses_count')
                              .left_joins(:course_instructors)
                              .group('admin_users.id')
    end
  end
end
